#
# h2. lib/imw/utils/misc.rb -- miscellaneous functions
#
# == About
#
# A collection of helpful functions in various places through the IMW
# source tree.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'uri'
require 'yaml'

def identify(obj)
  obj.hash
end

def announce(*args)
    $stderr.puts "%s: %s" % [Time.now, args.flatten.map(&:to_s).join("\t")]
end



# Returns the domain of the given URI, first scrubbing it of any
# prefixes we can ignore.
def domain(uri)
  # List of prefixes we can ignore.
  ignored_prefixes = ['www']
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
  parts = (ignored_prefixes.member?(parts[0]) ? parts[1...parts.size] : parts)
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


# puts "#{File.basename(__FILE__)}: Your Monkeywrench seems suddenly more utilisable." # at bottom
