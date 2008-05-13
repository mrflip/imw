#
# h2. imw/rip.rb -- Handles ripping data in various ways from the web.
#
# == Accessing Data
# 
# This module will access data online in a variety of formats
#
# * syndicated news feeds (RSS)
# * web pages and files by following following hyperlinks 
#   and/or recursively downloading web directories
#
# and using a variety of protocalls (HTTP, FTP, SFTP, etc.).
#
#
# == Processing Data 
#
# Data ripped from the web will not be processed by this module but
# only downloaded, checked for duplication, and saved (perhaps zipped)
# to the 'ripd' directory reserved for this dataset.
#
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'uri'

# List of prefixes we can ignore.
Ignored_prefixes = ['www']

# Returns the domain of the given URI, first scrubbing it of any
# prefixes we can ignore.
def domain(uri)
  uriobj = URI::parse(uri)
  if uriobj.host then
    host = uriobj.host
  elsif uriobj.path then
    host = uriobj.path.split('/')[0]
  else
    raise ArgumentError, "Invalid URI: #{uri}"
  end
  # remove any ignored prefixes from the hostname (i.e. - 'www')
  parts = host.split('.')
  parts = (Ignored_prefixes.member?(parts[0]) ? parts[1...parts.size] : parts)
  host = parts.join('.')
  return host
end

# Returns the reversed domain of the given URI, first scrubbing it of
# any prefixes we can ignore.  Will not reverse numeric addresses of
# the form 127.0.0.1
def reverse_domain(uri)
  begin
    d = domain(uri)
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


puts "#{File.basename(__FILE__)}: Dark branches crack like thunder at dusk as your Infinite Monkeywrench rips through the dense undergrowth." # at bottom
