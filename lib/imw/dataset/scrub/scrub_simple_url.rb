

module IMW
  module URIScrubber

    def scrubbed
      to_dirpath
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
end
