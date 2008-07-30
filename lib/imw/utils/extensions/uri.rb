#
# h2. lib/imw/utils/extensions/uri.rb -- extensions to uri module
#
# == About
#
# Some useful extensions to the +URI+ module.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'uri'

module URI

  # List of prefixes ignored when returning domains (or reversed
  # domains).
  IGNORED_PREFIXES = ['www']
  
  # Returns the domain of the given URI, first scrubbing it of any
  # prefixes we can ignore.
  def self.domain(uri)
      uriobj = self.parse(uri)
    if uriobj.host then
      host = uriobj.host
    elsif uriobj.path then
      host = uriobj.path.split('/')[0]
    else
      raise ArgumentError, "Invalid URI: #{uri}"
    end
    # remove any ignored prefixes from the hostname (i.e. - 'www')
    parts = host.split('.')
    parts = (IGNORED_PREFIXES.member?(parts[0]) ? parts[1...parts.size] : parts)
    host = parts.join('.')
    host
  end

  # Returns the reversed domain of the given URI, first scrubbing it of
  # any prefixes we can ignore.  Will not reverse numeric addresses of
  # the form 127.0.0.1
  def self.reverse_domain(uri)
    begin
      d = self.domain(uri)
      # check for numeric ip
      # in a TERRIBLE way that needs to be fixed!`
      if d=~/^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$/ then
        return d
      else
        return d.split('.').reverse.join('.')
      end
    rescue URI::InvalidURIError,ArgumentError
      raise $!
    end
  end
end

# puts "#{File.basename(__FILE__)}: In the end, it's either you or I." # at bottom
