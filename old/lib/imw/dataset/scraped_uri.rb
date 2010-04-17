# -*- coding: utf-8 -*-
module Linkish
  def self.included base
    base.class_eval do
      include DataMapper::Resource
      include Infochimps::Resource
      property      :id,              Integer,        :serial      => true
      property      :full_url,        String,         :length      => 255,    :nullable => false,                     :unique_index => true
      has_handle
      alias_method  :handle_generator, :full_url
      has_time_and_user_stamps
      #
      property      :name,            String,         :length      => 255,    :nullable => false, :default => ''
      #
      property      :file_path,       String,    :length => 1024
      property      :file_time,       DateTime
      property      :file_size,       Integer
      property      :file_sha1,       String,    :length => 40
      property      :tried_fetch,     DataMapper::Resource::Boolean
      property      :fetched,         DataMapper::Resource::Boolean
      #
      before :create, :make_uuid_and_handle
      before :create, :update_from_file!
    end
    base.extend ClassMethods
  end

  # ===========================================================================
  #
  # Delegate methods to uri
  #
  def uri
    @uri ||= Addressable::URI.parse(self.full_url)
  end
  # Dispatch anything else to the aggregated uri object
  def method_missing method, *args
    if self.uri.respond_to?(method)
      self.uri.send(method, *args)
    else
      super method, *args
    end
  end

  def to_s
    "<a href='#{self.uri.to_s}'>#{self.name}</a>" # <-- !! not escaped !!
  end

  # ===========================================================================
  #
  # ID, naming, etc
  #
  def normalize_url!
    u = Addressable::URI.parse(self.full_url).normalize
    self.full_url = u.to_s
  end

  # ===========================================================================
  #
  # Properly belongs in FileStore module
  #
  #
  # Refresh cached properties from our copy of the asset.
  #
  def update_from_file!
    self.make_uuid_and_handle # make sure this happened
    # Set the file path
    self.file_path = self.to_file_path if self.file_path.blank?
    # FIXME -- kludge to ripd_root
    if ! File.exist?(actual_path)
      self.fetched   = false
    else
      self.fetched   = self.tried_fetch = true
      self.file_size = File.size( actual_path)
      self.file_time = File.mtime(actual_path)
    end
    self.fetched
  end
  def actual_path
    path_to(:ripd_root, self.file_path)
  end

  # ===========================================================================
  #
  # Properly belongs in own module
  #

  IMW_WGET_OPTIONS = {
    :root       => :ripd_root,
    :wait       => 2,
    :noretry    => true,
    :log_level  => Logger::DEBUG,
    :clobber    => false,
  }
  #
  # Fetch from the web
  #
  def wget options={}
    options.reverse_merge! IMW_WGET_OPTIONS
    cd path_to(options[:root]) do
      if (not options[:clobber]) && File.file?(file_path) then
        IMW.log.add options[:log_level], "Skipping #{file_path}"; return
      end
      # Do the fetch
      mkdir_p File.dirname(actual_path)
      # defaults are --connect-timeout=infinity --read-timeout=900 --tries=20 acc. to man page
      cmd = %Q{wget -nv "#{full_url}" -O"#{actual_path}" --connect-timeout=5 --read-timeout=10 --tries=1 &}
      IMW.log.add(options[:log_level], cmd)
      IMW.log.add(options[:log_level], `#{cmd}`)
      self.tried_fetch = true
      sleep options[:wait] # please hammer don't hurt em
      update_from_file!
      self.save
      return self.fetched
    end
  end

  #
  #
  #
  def contents options={}
    wget options
    if fetched
      File.open actual_path
    end
  end

  # ===========================================================================
  #
  # Properly belongs in FileStore
  #

  protected
  #
  # The standard file path for this url's ripped cache
  #
  # * leading directory from reverse.dotted.host_scheme:port:user@password
  # * normalized path/file?query#fragment
  # * uuid formed from the
  #
  def to_file_path
    file_path_str = ""
    file_path_str << to_file_path_root_part
    file_path_str << to_file_path_path_part
    file_path_str << to_file_path_file_part
    file_path_str = self.class.path_str_encode(file_path_str)
    self.class.validate_roundtrip(file_path_str)
    file_path_str
  end
  def file_timestamp
    file_time.strftime("%Y%m%d-%H%M%S")
  end
  def to_file_path_with_timestamp
    to_file_path + file_timestamp
  end
  #
  # revhost_scheme:port:user@password -- omitting _scheme if it's http, and
  # omitting :port:user@password if all three are blank.
  #
  def to_file_path_root_part
    root_part_str = ""
    tld_host_frag = self.class.tier_path_segment(revhost, /^([^\.]+)\.([^\.]{1,2})/)
    root_part_str << revhost
    root_part_str << "_#{uri.scheme}"                           unless uri.scheme == 'http'
    root_part_str << ":#{uri.port}:#{uri.user}@#{uri.password}" unless uri.simple?
    root_part_str
  end
  def to_file_path_path_part
    uri.path.to_s
  end
  def to_file_path_file_part
    file_path_str = ""
    file_path_str << "?#{uri.query}"        unless uri.query.nil?
    file_path_str << "##{uri.fragment}"     unless uri.fragment.nil?
    file_path_str << "-#{self.uuid}"
  end
  public


  module ClassMethods
    #
    # find_or_creates from url
    #
    # url is heuristic_parse'd and normalized by Addressable before lookup:
    #   "Converts an input to a URI. The input does not have to be a valid URI —
    #   the method will use heuristics to guess what URI was intended. This is not
    #   standards compliant, merely user-friendly.
    #
    def find_or_create_from_url url_str
      link = self.find_or_new_from_url url_str
      link.save
      link
    end
    def find_or_new_from_url url_str # :nodoc:
      url_str = Addressable::URI.heuristic_parse(url_str).normalize.to_s
      link = self.first( :full_url => url_str ) || self.new( :full_url => url_str )
      link.make_uuid_and_handle
      link.update_from_file!
      link
    end
    def find_or_create_from_file_path ripd_file
      url_str = Link.url_from_file_path(ripd_file)
      link = self.first( :full_url => url_str.to_s ) || self.new( :full_url => url_str.to_s )
      link.file_path = ripd_file
      link.make_uuid_and_handle
      link.update_from_file!
      link.save
      link
    end
    #
    # Decode url from its file_path
    #
    def url_from_file_path fp
      fp = path_str_decode(fp)
      m = (%r{\A
            (#{Addressable::URI::HOST_TLD})  # tld tier
           /(..?)                            # revhost tier
           /([^/\:_]+)                       # revhost
        (?:_([^/\:]+))?                      # _scheme
        (?::(\d*):([^/]*)@([^@/]*?))?        # :port:user@password
           /(?:(.*?)/)?                      # /dirs/
            ([^/]*)                          #  file
           -([a-f0-9]{32})                   # -uuid
                                \z}x.match(fp))
      raise "Can't extract url from file path #{fp}" if !m
      fp_host, fp_scheme, fp_port, fp_user, fp_pass, fp_path, fp_file, fp_uuid = m.captures
      fp_host     = fp_host.split('.').reverse.join('.')
      fp_scheme ||= 'http'
      fp_pass     = ":#{fp_pass}"             unless fp_pass.blank?
      fp_userpass = "#{fp_user}#{fp_user}@"   unless fp_user.blank?
      fp_port     = ":#{fp_port}"             unless fp_port.blank?
      fp_path     = File.join(*[fp_path, fp_file].compact)
      "#{fp_scheme}://#{fp_userpass}#{fp_host}#{fp_port}/#{fp_path}"
    end
    #
    # to control files-per-directory madness, take a path segment like "foobar" in
    #   blah.com/top/foobar/directory
    # and transform into
    #   blah.com/top/fo/foobar/directory
    #
    # Ex.
    #   self.class.tier_path_segment('a_username')
    #   # => 'a_/a_username'
    #   self.class.tier_path_segment('1')
    #   # => '1/1'
    #   self.class.tier_path_segment('com.twitter', /^([^\.]+)\.([^\.]{1,2})/)
    #   # => 'com/tw/com.twitter'
    #
    def self.tier_path_segment(path_seg, re=/(..?)/)
      frag_seg = re.match(path_seg).captures
      raise "Can't tier path_seg #{path_seg} using #{re}" if frag_seg.blank?
      File.join(* [frag_seg, path_seg].flatten )
    end
    #
    #
    # It's really bad if you can't roundtrip --
    # since saving is the rare case (only done once!) we insist on checking.
    #
    def self.validate_roundtrip file_path_str
      # uu = self.class.url_from_file_path(file_path_str)
      # puts "*"*75, uri.to_hash.inspect, ['path str', file_path_str, 'uri', uri.to_s, 'rt', uu.to_s].inspect
      return_trip_url = Addressable::URI.parse(self.class.url_from_file_path(file_path_str))
      raise "crapsticks: uri doesn't roundtrip #{file_path_str} to #{uri.to_s}: #{return_trip_url}" if return_trip_url != uri
    end
    #
    # Uses a similar scheme as the 'Quoted Printable' encoding, but more strict
    # and without linebreaking or anything. The intent is to reversibly and
    # recognizably store URLs to disk with names that (apart from path) do not
    # need to be further escaped in filesystem, URL, database or HTML.
    #
    # The only characters in a path_encoded string are alpha-numeric /_-.=
    #
    # Rules:
    # * Any character that is not alphanumeric, and is not /_-.  is encoded as an
    #   equals sign = followed by its upper-case hex encoding.
    #
    # * Furthermore, in any sequence of repeated '.' characters, all after the
    #   first are hex encoded; same with '/'.
    #
    # Ex.
    #   path_encode("www.measuringworth.com/datasets/consumer/result.php?use[]=VCB&use[]=CU&use[]=SZ&year_source=1900&year_result=2007"
    #   # => www.measuringworth.com/datasets/consumer/result.php=3Fuse=5B=5D=3DVCB=26use=5B=5D=3DCU=26use=5B=5D=3DSZ=26year_source=3D1900=26year_result=3D2007
    #
    # Code inspired by "Glenn Parker's response to ruby quiz #23"http://www.rubyquiz.com/quiz23.html
    #
    def path_str_encode(str)
      str.gsub(%r{\.(\.+)}){|chars| '.'+path_encode_chars(chars) }
      str.gsub(%r{\/(\/+)}){|chars| '/'+path_encode_chars(chars) }
      str.gsub(%r{[^A-Za-z0-9/_\-\.]+}){|chars| path_encode_chars(chars) }
    end
    #
    # See the notes in path_encode
    #
    def path_str_decode(str)
      str.gsub(/\+([\dA-F]{2})/){ $1.hex.chr }
    end
    protected
    def path_encode_chars(chars) # :nodoc:
      # send each character to an equals sign followed by its uppercase hex encoding
      encoded = "";
      chars.each_byte{|c| encoded << "+%02X" % c }
      encoded
    end
    public
  end
end
