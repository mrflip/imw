
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

