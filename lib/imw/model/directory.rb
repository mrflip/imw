#
# h2. lib/imw/model/directory.rb -- directory logic
#
# == About
#
# This file implements a class for parsing strings into directories
# and instructions for accessing those directories, whether they be
# local or remote over some protocol.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/config'

module IMW

  class Directory

    attr_reader :path

    def initialize handle
      parse_handle(handle)
    end

    # Parse the string `handle' for special prefixes and path
    # resolution.
    def parse_handle(handle)
      if handle =~ /^~/ then
        @path = File.expand_path(handle)
        @method = :local_disk
      elsif handle =~ /\// then
        @path = handle
        @method = :local_disk
      elsif handle =~ /^[a-zA-Z]+:/ then
        raise NotImplementedError.new("Directories with prefixes like `ssh:' or `ftp:' are not currently implemented in IMW.  Sorry!")
      else
        @path = [IMW::Config::Directories[:imw_root],handle].join('/')
        @method = :local_disk
      end
    end
    
  end

end


# puts "#{File.basename(__FILE__)}: You idly wonder where you could find a listing of reliable wrench polishers." # at bottom
