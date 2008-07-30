#
# h2. lib/imw/model/directory.rb -- directory logic
#
# == About
#
# Defines a <tt>IMW::Directory</tt> class which abstracts the
# differences between local and remote directories and adds some
# convenience methods.
#
# There's nothing here yet but a non-functioning version of a local
# directory.  For now it's probably best to pretend that this class
# doesn't actually exist.  We'll write it and give it real
# functionality if we need to.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils'

module IMW

  class Directory

    # Methods of directory access that have been implemented.
    ACCESS_METHODS = [:local]

    attr_reader :path, :method

    private
    def initialize handle
      parse_handle(handle)
    end

    # Parse the string `handle' for special prefixes and path
    # resolution.
    def parse_handle(handle)
      if /^[a-zA-Z]+:/.match handle then
        raise IMW::NotImplementedError.new("Directories with prefixes like `ssh:' or `ftp:' are not currently implemented in IMW.  Sorry!")
      else
        @path = File.expand_path(handle)
        @method = :local
      end
    end
    
  end
end

# puts "#{File.basename(__FILE__)}: You idly wonder where you could find a listing of reliable wrench polishers." # at bottom
