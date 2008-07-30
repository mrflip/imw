#
# h2. lib/imw/utils/extensions/string.rb -- string extensions
#
# == About
#
# Implements some useful extensions to the +String+ class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

class String
  
  # Does the string end with the specified +suffix+ (stolen from
  # <tt>ActiveSupport::CoreExtensions::String::StartsEndsWith</tt>)?
  def ends_with?(suffix)
    suffix = suffix.to_s
    self[-suffix.length, suffix.length] == suffix      
  end

  # Does the string start with the specified +prefix+ (stolen from
  # <tt>ActiveSupport::CoreExtensions::String::StartsEndsWith</tt>)?
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end
  
end

# puts "#{File.basename(__FILE__)}: You tie a long string to your Monkeywrench, place it on the ground, and hide around the corner with the string in your hand, waiting for passersby to try and pick up your tool." # at bottom
