# -*- coding: utf-8 -*-
require 'imw/dataset/uri'
require 'imw/dataset/uuid'
require 'dm-serializer'
require 'imw/utils/extensions/class/attribute_accessors'

class Link
  include DataMapper::Resource
  include Infochimps::Resource
  # note: no trailing /
  UUID_INFOCHIMPS_LINKS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/links') unless defined?(UUID_INFOCHIMPS_LINKS_NAMESPACE)
  UUID_INFOCHIMPS_ASSETS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/assets') unless defined?(UUID_INFOCHIMPS_ASSETS_NAMESPACE)
  property      :id,                            Integer,        :serial      => true
  property      :full_url,                      String,         :length      => 255,    :nullable => false,                     :unique_index => true
  has_handle
  has_time_and_user_stamps
  #
  property      :linkable_id,                   Integer,                                                                        :index => :linkable_index
  property      :linkable_type,                 String,         :length      =>  40,    :nullable => false,                     :index => :linkable_index
  #
  property      :role,                          String,         :length      =>  40,    :nullable => false, :default => '',     :index => :linkable_index
  property      :name,                          String,         :length      => 255,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  #
  property      :file_path,       String,    :length => 1024
  property      :file_time,       DateTime
  property      :file_size,       Integer
  property      :file_sha1,       String,    :length => 40
  property      :tried_fetch,     Boolean
  property      :fetched,         Boolean
  #
  belongs_to    :linkable, :class_name => 'Dataset', :child_key => [:linkable_id],       :polymorphic  => true
  before :save, :fake_polymorphism; def fake_polymorphism() self.linkable_type = 'Dataset' end
  before :create, :make_uuid_and_handle
  before :create, :update_from_file!

  # ---------------------------------------------------------------------------
  # Validations


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

  # ===========================================================================
  #
  # ID, naming, etc
  #
  def make_uuid_and_handle
    self.handle ||= full_url
    self.uuid   ||= UUID.sha1_create(UUID_INFOCHIMPS_LINKS_NAMESPACE, self.handle).hexdigest
  end

  #
  # find_or_creates from url
  #
  # url is heuristic_parse'd and normalized by Addressable before lookup:
  #   "Converts an input to a URI. The input does not have to be a valid URI —
  #   the method will use heuristics to guess what URI was intended. This is not
  #   standards compliant, merely user-friendly.
  #
  def self.find_or_new_from_url url_str
    u = Addressable::URI.heuristic_parse(url_str).normalize
    link = self.first( :full_url => u.to_s ) || self.new( :full_url => u.to_s )
    link.make_uuid_and_handle
    link.update_from_file!
    link
  end


  # ===========================================================================
  #
  # Properly belongs in FileStore module
  #
  #
  # Refresh cached properties from our copy of the asset.
  #
  def update_from_file!
    # Set the file path
    self.file_path = self.to_file_path if self.file_path.blank?
    # FIXME -- kludge to ripd_root
    disk_file = path_to(:ripd_root, self.file_path)
    if ! File.exist?(disk_file)
      self.fetched   = false
    else
      self.fetched   = self.tried_fetch = true
      self.file_size = File.size( disk_file)
      self.file_time = File.mtime(disk_file)
    end
    self.fetched
  end

  IMW_WGET_OPTIONS = {
    :root       => :ripd_root,
    :wait       => 2,
    :noretry    => true,
    :log_level  => LOGGER::DEBUG,
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
      cmd = %Q{wget -nv "#{full_url}" -O"#{self.file_path}"}
      IMW.log.add(options[:log_level], cmd)
      IMW.log.add(options[:log_level], `#{cmd}`)
      self.tried_fetch = true
      update_from_file!
      self.save
      sleep options[:wait] # please hammer don't hurt em
      return self.fetched
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
    file_path_str << uri.path.to_s
    file_path_str << "?#{uri.query}"        unless uri.query.nil?
    file_path_str << "##{uri.fragment}"     unless uri.fragment.nil?
    file_path_str << "-#{self.uuid}"
    file_path_str = self.class.path_str_encode(file_path_str)
    #
    # It's really bad if you can't roundtrip --
    # since saving is the rare case we insist on checking.
    # uu = self.class.url_from_file_path(file_path_str)
    # puts "*"*75, uri.to_hash.inspect, ['path str', file_path_str, 'uri', uri.to_s, 'rt', uu.to_s].inspect
    raise "crapsticks: uri doesn't roundtrip #{file_path_str} to #{uri.to_s}" if self.class.url_from_file_path(file_path_str) != uri
    file_path_str
  end
  #
  # revhost_scheme:port:user@password -- omitting _scheme if it's http, and
  # omitting :port:user@password if all three are blank.
  #
  def to_file_path_root_part
    root_part_str = ""
    root_part_str << revhost
    root_part_str << "_#{uri.scheme}"                           unless uri.scheme == 'http'
    root_part_str << ":#{uri.port}:#{uri.user}@#{uri.password}" unless uri.simple?
    root_part_str
  end
  public
  #
  # Decode url from its file_path
  #
  def self.url_from_file_path fp
    fp = path_str_decode(fp)
    m = (%r{\A
            ([^/\:_]+)
        (?:_([^/\:]+))?                  # _scheme
        (?::(\d*):([^/]*)@([^@/]*?))?    # :port:user@password
           /(?:(.*?)/)?                  # /dirs/
            ([^/]*)                      #  file
           -([a-f0-9]{32})               # -uuid
                                \z}x.match(fp))
    raise "Can't extract url from file path #{fp}" if !m
    fp_host, fp_scheme, fp_port, fp_user, fp_pass, fp_path, fp_file, fp_uuid = m.captures
    fp_host     = fp_host.split('.').reverse.join('.')
    fp_scheme ||= 'http'
    fp_userpass, fp_port = ["#{fp_user}:#{fp_pass}@", ":#{fp_port}"] unless [fp_user, fp_pass, fp_port].join('').blank?
    fp_path     = File.join(*[fp_path, fp_file].compact)
    Addressable::URI.parse("#{fp_scheme}://#{fp_userpass}#{fp_host}#{fp_port}/#{fp_path}")
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
  def self.path_str_encode(str)
    str.gsub(%r{\.(\.+)}){|chars| '.'+path_encode_chars(chars) }
    str.gsub(%r{[^A-Za-z0-9/_\-\.]+}){|chars| path_encode_chars(chars) }
  end
  #
  # See the notes in path_encode
  #
  def self.path_str_decode(str)
    str.gsub(/\+([\dA-F]{2})/){ $1.hex.chr }
  end
  protected
  def self.path_encode_chars(chars) # :nodoc:
    # send each character to an equals sign followed by its uppercase hex encoding
    encoded = "";
    chars.each_byte{|c| encoded << "+%02X" % c }
    encoded
  end
  public
end


# :host, :scheme, :port, :user, :password
# :path, :query, :fragment
