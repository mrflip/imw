#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'addressable/uri'
require 'imw/dataset/datamapper'

#
#
# Database image of a URI object.  See
#   http://www.ruby-doc.org/stdlib/libdoc/uri/rdoc/
#
# FIXME -- this should, y'know, actually be composed or inherit from URI
#
class DM_URI
  include DataMapper::Resource
  property      :id,                    Integer,   :serial   => true
  property      :scheme,                String,    :nullable => false
  property      :user,                  String,    :nullable => false, :default => ''
  property      :password,              String,    :nullable => false, :default => ''
  property      :host,                  String,    :nullable => false
  # note: port is not an integer: URI returns a string and it's almost always used as a string.
  property      :port,                  String,    :nullable => true
  property      :path,                  Text,      :nullable => false, :default => ''
  property      :query,                 Text,      :nullable => false, :default => ''
  property      :fragment,              Text,      :nullable => false, :default => ''

  #
  # Mix in a URI by Aggregation or whatever it's called  
  #
  def uri
    @uri = Addressable::URI.new(*self.attributes.values_at(
        :scheme, :user, :password, :host, :port, :path, :query, :fragment))
  end
  # Dispatch anything else to the aggregated uri object
  def method_missing method, *args
    self.uri.send(method, *args)
  end

  #
  # find_or_creates from parsed (using Addressable::URI.heuristic_parse) URL string
  #
  # quoting:
  #   "Converts an input to a URI. The input does not have to be a valid URI —
  #   the method will use heuristics to guess what URI was intended. This is not
  #   standards compliant, merely user-friendly.
  #
  def self.find_or_create_from_url url_str
    u = Addressable::URI.heuristic_parse(url_str).normalize
    dm_uri = self.find_or_create(u.to_hash)
  end

  #
  # convert the uri to its representation as a filename
  #
  def to_pathname
    File.join(host, path).gsub(%r{/$},'') # kill terminal '/'
  end

end
