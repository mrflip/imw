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

module Addressable
  #
  # Add the #scrubbed and #revhost calls
  #
  class URI # < Addressable::URI
    include IMW::URIScrubber

    SAFE_CHARS      = %r{a-zA-Z0-9\-\._!\(\)\*\'}
    PATH_CHARS      = %r{#{SAFE_CHARS}\$&\+,:=@\/;}
    RESERVED_CHARS  = %r{\$&\+,:=@\/;\?\%}
    UNSAFE_CHARS    = %r{\\ \"\#<>\[\]\^\`\|\~\{\}}
    HOST_HEAD     = '(?:[A-Z0-9\-]+\.)+'
    HOST_TLD      = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'

    def host_valid?
      !!(host =~ %r{\A#{HOST_HEAD}#{HOST_TLD}\z}i)
    end

    def path_valid?
      !!(path =~ %r{\A[#{PATH_CHARS}]*\z})
    end

    #
    # can the uri be reproduced from its scrubbed representation?
    #
    def simple?
      host_valid? &&
        path_valid? &&
        self.to_hash.values_at(:query, :port, :fragment, :password, :user).join.blank?
    end

    #
    # +revhost+
    # the dot-reversed host:
    #   foo.company.com => com.company.foo
    #
    def revhost
      return host unless host =~ /\./
      host.split('.').reverse.join('.')
    end
    #
    # +uuid+  -- RFC-4122 ver.5 uuid; guaranteed to be universally unique
    #
    # See
    #   http://www.faqs.org/rfcs/rfc4122.html
    #
    def uuid
      uuid_raw.hexdigest
    end
    def uuid_path
      uuid_raw.to_path
    end
    def uuid_raw
      UUID.sha1_create(UUID_URL_NAMESPACE, self.normalize.to_s)
    end
  end
end


class UUID
  def to_path
    'urn_uuid/' + to_s.gsub(/[\:\-]/,'/')
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
