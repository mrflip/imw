require 'imw/utils/uri'
module IMW
    #
    # Even a moderately large scrape will soon become cumbersome on disk.
  class CachedUri
    attr_accessor :uri
    attr_accessor :timestamp
    def initialize new_uri, timestamp=nil
      self.uri = case new_uri
                 when Addressable::URI  then new_uri
                 when String            then Addressable::URI.parse(new_uri)
                 end
      self.timestamp = timestamp
    end


    # ===========================================================================
    #
    # URI => File path
    #

    #
    # The standard file path for this url's ripped cache
    #
    # * leading directory from reverse.dotted.host_scheme:port:user@password
    # * normalized path/file?query#fragment
    # * uuid formed from the
    #
    def file_path
      fp = [
        file_root_part,
        [ file_host_part,
          file_connection_part ].join(''),
        file_timestamp_dir_part,
        [ file_path_part,
          file_query_part,
          file_fragment_part,
          file_timestamp_part,
          file_extension_part ].join('')
        ].reject(&:blank?)
      # self.class.validate_roundtrip(fp)
      @file_path = fp.join('/')
    end

    #
    # Cascade urls into a subdirectory of first its TLD and then the
    # first two letters of the second-level-domain.
    #
    # This indiscriminately only cascades the first two dotted host segments.
    # Everything withiin .ac.uk, for instance, will land in _uk/_ac. Also, URI's
    # lacking either host component will all land in the same '_' directory. In
    # such cases you may wish to override file_path_part to give a cascade if
    # necessary.
    #
    # Ex:
    # CachedUri.new('http://www.google.com').file_root_part
    # # => "_com/_go"
    # CachedUri.new('http://x.com/#files').file_root_part
    # # => "_com/_x"
    # CachedUri.new('http://localhost/foo').file_root_part
    # # => "_localhost/_"
    # CachedUri.new('file:///home/flip/ics').file_root_part
    # # => "_/_/"
    #
    def file_root_part
      tld, sld, _ = encode_path_part(uri.revhost).split(/\./)
      sld_prefix = sld.to_s[0..1]
      "_#{tld}/_#{sld_prefix}"
    end

    #
    # Use the reverse-dotted-host as a directory
    #
    # CachedUri.new('http://www.google.com').file_host_part
    # # => "com.google.www"
    # CachedUri.new('http://x.com/#files').file_host_part
    # # => "com.x"
    # CachedUri.new('http://localhost/foo').file_host_part
    # # => "localhost"
    # CachedUri.new('file:///home/flip/ics').file_host_part
    # # => ""
    #
    #
    def file_host_part
      # encoding should be unneccessary but hey
      encode_path_part(uri.revhost)
    end

    #
    # Encode the scheme, host, port, user and password parts of the file path
    #
    # If the scheme is http port 80, and the user and password are blank, this
    # is blank.
    #
    # Otherwise, all non-alphanumeric characters in the scheme, port, username
    # and password are encoded, then joined with '_' underscores in that order.
    #
    # CachedUri.new('http://www.google.com').file_host_part
    # # => "com.google.www"
    # CachedUri.new('ftp://ftp.kernel.org').file_host_part
    # # => "com.x"
    # CachedUri.new('http://localhost:8888').file_host_part
    # # => "localhost"
    # CachedUri.new('https://foo:bar@auth.required.com/').file_host_part
    # # => ""
    #
    def file_connection_part
      return "" if uri.simple_connection_part?
      tail = uri.to_hash.values_at(:scheme, :port, :user, :password )
      tail.map!{|s| Addressable::URI.encode_segment(s.to_s, "a-zA-Z0-9") }
      "_" + tail.join("_")
    end

    [ 'http://www.google.com', 'http://www.google.com/', 'http://x.com/#files',      'ftp://ftp.kernel.org',  'ftp://ftp@ftp.kernel.org/',      'urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6',      'doi:alpha-beta/182.342-24', 'doi:10.abc/ab/cd/ef', 'doi:1.23/2002/january/21/4690',      'https://foo:bar@auth.required.com/',      'http://my.resolver.inc/resolve?id=doi%3Aalpha-beta%2Fmsws',      'http://your!&mom:pas-swd@foo.com/ba r?hi=there',      'http://foo.com/path1/path+2/path3;pathq/?q=val#anchor',      'http://foo.com/path1/path+2/path3;pathq/#anchor',      'http://foo.com/path1/path+2/path3;pathq/file?q=val#anchor',      'http://foo.com/path1/path+2/path3;pathq/file.ext?q=val#anchor',      'http://foo.com/path1/path+2/path3;pathq/file.ext',    ]

    #
    # Prepare the url's host part in the file path
    #
    # Each part of the path between / slashes is encoded (allowing alphanumeric
    # plus _.-). Additionally, due to the cascading rule (ignore directories
    # starting with an '_' underscore when re-assembling the URI) we encode a
    # leading underscore if it appears in the literal URI path.
    #
    def file_path_part
      pth = uri.path.to_s
      # Need to preserve a trailing slash on the last element path
      if (m = %r{\A(.*)(/)\z}.match(pth)) then pth = $1; trailing = '%2F' else trailing = '' end
      # Discard leading slash (it will be supplied when path is joined)
      pth = uri.path.gsub(%r{^/}, '')
      # Split into dirs
      file_parts = pth.split(%r{/})
      # encode each segment (including leading underscore)
      file_parts.map!{|s| encode_path_part(s).gsub(/^_/, "%5F") }
      file_parts.join('/') + trailing
    end

    # Encode the query part of the file path
    def file_query_part
      file_part = uri.query ? "?#{uri.query}" : ""
      encode_path_part(file_part)
    end

    # Encode the fragment part of the file path
    def file_fragment_part
      file_part = uri.fragment ? "##{uri.fragment}" : ""
      encode_path_part(file_part)
    end

    # Encode the fragment part of the file path
    #
    # Note that +
    def file_timestamp_part
      timestamp ? timestamp.strftime("+%Y%m%d%H%M%S") : ""
    end
    def file_timestamp_dir_part
      timestamp ? timestamp.strftime("_%Y%m%d") : ""
    end

    def timestamp
      @timestamp ||= Time.now
    end

    # Regular expression to match a file extension part
    EXTENSION_RE = %r{(\.[a-zA-Z0-9]{1,7})\z}
    # Encode the extension part of the file path
    #
    # This part has no impact on decoding and can be fooled in various ways.
    # It's useful, though, in making files retain their correct operating system
    # file type associations
    #
    def file_extension_part
      m = EXTENSION_RE.match( encode_path_part(uri.path) )
      m ? m.captures.first.to_s : ""
    end

    # ===========================================================================
    #
    #
    # Decode url from its file_path
    #
    def self.url_from_file_path fp
      m = (%r{\A
            _(?:#{Addressable::URI::HOST_TLD})?   # tld cascade
           /_\w{0,2}                         # revhost tier
           /([a-zA-Z0-9\.\-]*)               # revhost
        (?:_([a-zA-Z0-9%]*)                  # _scheme
           _(\d*)                            # _port
           _([a-zA-Z0-9%]*)                  # _user
           _([a-zA-Z0-9%]*)  )?              # _password
           /_\d{8}                           # scrape date cascade
           /([\w%\./\-]*?)                   # /path
          \+(\d{14})?                   # +timestamp
            (\.[a-zA-Z0-9]{1,7})?            # .extension
                                \z}x.match(fp))
           # /(?:([\w%\./\-]*?)/)?             # /dirs/
           #  ([\w%\.\-]*)                     #  file

      unless m then warn "Can't extract url from file path #{fp}" ; return nil end
      fp_host, fp_scheme, fp_port, fp_user, fp_pass, fp_path, fp_timestamp, fp_ext = m.captures
      fp_host     = fp_host.split('.').reverse.join('.')
      fp_scheme ||= 'http'
      fp_pass     = ":#{fp_pass}"             unless fp_pass.blank?
      fp_userpass = "#{fp_user}#{fp_pass}@"   unless fp_user.blank?
      fp_port     = ":#{fp_port}"             unless fp_port.blank?
      # fp_path     = File.join(*[fp_path, fp_file].compact)
      # fp_path = '/'+fp_path unless fp_path =~ %r{^/}
      fp_connection = "//#{fp_userpass}#{fp_host}#{fp_port}" unless fp_host.blank?
      File.join(
        *[ decode_path_part("#{fp_scheme}:#{fp_connection}"), decode_path_part(fp_path) ].reject(&:blank?) )
    end

    #
    # Apply standard URI encoding, allowing only alphanumeric plus underscore
    # dot and dash to survive.
    #
    def encode_path_part path_part
      Addressable::URI.encode_segment(path_part, "a-zA-Z0-9_\\.\\-") || ""
    end
    #
    # decode segment.  We can do this regardless of what character subset was encoded.
    #
    def self.decode_path_part(str)
      Addressable::URI.unencode_segment(str)
    end

  end
end
