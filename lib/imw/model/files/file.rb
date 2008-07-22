#
# h2. lib/imw/model/file.rb -- base class for files 
#
# == About
#
# Defines a base class for classes for specific filetypes to subclass.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/model/files/compressible'
require 'imw/model/files/archive'

require 'imw/utils'

module IMW

  module Files

    class File

      include IMW::Files::Compressible

      attr_reader :path, :dirname, :basename, :extension

      def initialize path
        set_path path
      end

      def set_path(path)
        path = File.expand_path path
        raise IMW::PathError.new("#{path} is a directory") if File.directory? path
        @path = path      
        @dirname = File.dirname @path
        @basename = File.basename @path
        @extname = File.extname @path
        @filename = @basename + '.' + @extname
      end

      # Is there a real file at the path of this File?
      def exist?
        File.exist? @path ? true : false
      end

    end

  end

end

# puts "#{File.basename(__FILE__)}: At the very bottom of the office building, wedged between a small boulder and a rotting log you see a weathered manilla file folder.  The writing on the tab is too faded to make out." # at bottom
