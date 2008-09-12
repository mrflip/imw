require 'scrub'
require 'addressable/uri'


module IMW
  # note: no trailing /
  UUID_INFOCHIMPS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org') unless defined?(UUID_INFOCHIMPS_NAMESPACE)

  module URIScrubber
    # lowercase; only a-z, num, . -
    def scrubbed_revhost
      return unless revhost
      revhost.downcase.gsub(/[^a-z0-9\.\-]+/i, '')  # note: no _
    end

    # only a-z A-Z, num, .-_/
    def scrubbed_path
      # Kill weird chars
      path_part = path.gsub(%r{[^a-zA-Z0-9\.\-_/]+}, '_')
      # Compact (killing foo/../bar, etc)
      path_part = path_part.gsub(%r{/[^a-zA-Z0-9]+/}, '/').gsub(%r{/\.\.+/}, '.')
      # Kill leading & trailing non-alnum
      path_part = path_part.gsub(%r{[^a-zA-Z0-9]+$}, '').gsub(%r{^[^a-zA-Z0-9]+}, '')
    end

    def scrubbed
      to_dirpath
    end

    def path_split
      path_split_str path
    end

    def to_dirpath
      scrubbed = join_non_blank '/', to_rootpath, scrubbed_path
    end
    def to_filepath
      print path
      dirname, basename, ext = path_split_str(scrubbed_path)
      basename = join_non_blank '-', basename, uuid
      basename = join_non_blank '.', basename, ext
      join_non_blank '/', to_rootpath, dirname, basename
    end

  protected
    #
    # Like File.split but heuristically handles things like .tar.bz2:
    #
    #   foo.        => ['foo.', '']
    #   foo.tar.gz  => ['foo.', '']
    #   foo.tar.bz2 => ['foo.', '']
    #   foo.yaml    => ['foo', '']
    #
    def path_split_str str
      if str =~ %r{/.+\z}
        dirname, basename = %r{\A(.*)/([^/]+)\z}.match(str).captures
      else
        dirname, basename = ['', str]
      end
      if basename =~ %r{.+\.[^\.]+}
        basename, ext = /\A(.+?)\.(tar\.gz|tar\.bz2|[^\.]+)\z/i.match(basename).captures
      else
        basename, ext = [basename, '']
      end
      p ['----', dirname, basename, ext]
      [dirname, basename, ext]
    end

    # remove all blank components, join the rest with separator
    def join_non_blank separator, *strs
      strs.reject(&:blank?).join(separator)
    end
    # if http:  revhost
    # else:     revhost_scheme
    def to_rootpath
      return '' if revhost.blank?
      revhost + ((scheme == 'http') ? '' : "_#{scheme}")
    end
  end
end

module Scrub
  #
  # start with a letter, and contain only A-Za-z0-9_
  #
  class SimplifiedURL < Scrub::Generic
    self.complaint  = "should follow our zany simplified URL rules: com.host.dot-reversed:schemeifnothttp/path/seg_men-ts/stuff.ext-SHA1ifweird"
    self.validator  = %r{#{Addressable::URI::SAFE_CHARS}#{Addressable::URI::RESERVED_CHARS}}u
    self.replacer   = ''
    include Scrub::Lowercased
    attr_accessor :uri

    def valid? str
      str.to_s.downcase == sanitize(str)
    end

    def sanitize str
      # if this fails just normalize once, or don't set $KCODE: http://bit.ly/1664vp
      uri = Addressable::URI.heuristic_parse(str.to_s).normalize
      # print [uri.host, uri.host_valid?, uri.path, uri.path_valid?].inspect
      if uri.host_valid?
        uri.scrubbed
      else
        uri.uuid_path
      end
    end
  end

  #
  # start with a letter, and contain only A-Za-z0-9_
  #
  class Handle < Scrub::Generic
    self.complaint  = ""
    self.validator  = %r{}u
    self.replacer   = ''
    include Scrub::Lowercased
    attr_accessor :uri

    def valid? str
      str.to_s.downcase == sanitize(str)
    end

    def sanitize str
      # if this fails just normalize once, or don't set $KCODE: http://bit.ly/1664vp
      uri = Addressable::URI.heuristic_parse(str.to_s).normalize
      # print [uri.host, uri.host_valid?, uri.path, uri.path_valid?].inspect
      if uri.host_valid?
        uri.scrubbed
      else
        uri.uuid_path
      end
    end
  end
end
