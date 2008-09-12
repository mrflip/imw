# -*- coding: utf-8 -*-
require 'uri'
class Link
  include DataMapper::Resource
  # Delegate methods to uri
  def uri
    @uri ||= Addressable::URI.heuristic_parse(self.full_url).normalize
  end
  # Dispatch anything else to the aggregated uri object
  def method_missing method, *args
    if self.uri.respond_to?(method)
      self.uri.send(method, *args)
    else
      super method, *args
    end
  end

  #
  # find_or_creates from url
  #
  # url is heuristic_parse'd and normalized by Addressable before lookup:
  #   "Converts an input to a URI. The input does not have to be a valid URI —
  #   the method will use heuristics to guess what URI was intended. This is not
  #   standards compliant, merely user-friendly.
  #
  def self.find_or_create_from_url url_str
    u = Addressable::URI.heuristic_parse(url_str).normalize
    link = self.find_or_create :full_url => u.to_str
  end


end
