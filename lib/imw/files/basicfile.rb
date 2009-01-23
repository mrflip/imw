#
# h2. lib/imw/files/file.rb -- base class for files 
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
# puts "#{File.basename(__FILE__)}: At the very bottom of the office building, wedged between a small boulder and a rotting log you see a weathered manilla file folder.  The writing on the tab is too faded to make out." # at bottom

require 'fileutils'

require 'imw/utils'

module IMW
  module Files
    module BasicFile

      attr_reader :path, :dirname, :basename, :extname, :name

      protected
      def path=(path)
        path = IMW.path_to(path)
        raise IMW::PathError.new("#{path} is a directory") if ::File.directory? path
        @path = path      
        @dirname = ::File.dirname @path
        @basename = ::File.basename @path
        @extname = find_extname @path
        @name = @basename[0,@basename.length - @extname.length]
      end

      # Some files (like <tt>.tar.gz</tt>) have an extension which is
      # not what <tt>File.extname</tt> will provide so this method is
      # used instead.  It can be overridden by a subclass.
      def find_extname path
        ::File.extname path
      end

      public
      # Is there a real file at the path of this File?
      def exist?
        ::File.exist?(@path) ? true : false
      end

      # Delete this file.
      def rm
        raise IMW::PathError.new("cannot delete #{@path}, doesn't exist!") unless exist?
        FileUtils.rm @path
      end

      # Copy this file to +path+.
      #
      # Options include
      #
      # <tt>:force</tt> (false):: raise an error if the new extension
      # isn't the same as the old extension unless <tt>:force</tt> is
      # true.
      def cp path, opts = {}
        opts.reverse_merge!({:force => false})
        raise IMW::PathError.new("cannot copy from #{@path}, doesn't exist!") unless exist?
        new_extname = find_extname path
        unless new_extname == @extname
          raise IMW::Error.new("new extension #{new_extname} isn't the same as the old extension #{@extname}") unless opts[:force]
        end
        FileUtils.cp @path,path
        self.class.new(path)
      end

      # Move this file to +path+.
      #
      # Options include
      #
      # <tt>:force</tt> (false):: raise an error if the new extension
      # isn't the same as the old extension unless <tt>:force</tt> is
      # true.
      def mv path, opts = {}
        opts.reverse_merge!({:force => false})        
        raise IMW::PathError.new("cannot move from #{@path}, doesn't exist!") unless exist?
        new_extname = find_extname path
        unless new_extname == @extname
          raise IMW::Error.new("new extension #{new_extname} isn't the same as the old extension #{@extname}") unless opts[:force]
        end
        FileUtils.mv @path,path
        self.class.new(path)
      end
    end
  end
end


