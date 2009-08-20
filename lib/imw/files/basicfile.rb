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

      attr_reader :uri, :path, :dirname, :basename, :extname, :name

      protected

      def uri= uri
        @uri = case 
               when uri.is_a?(String); URI.parse(uri)
               when uri.is_a?(URI::Generic) || uri.superclass.is_a?(URI::Generic); uri
               end
        @path = self.uri.path
        @dirname = ::File.dirname @path
        @basename = ::File.basename @path
        @extname = find_extname
        @name = @basename[0,@basename.length - @extname.length]
      end

      # Some files (like <tt>.tar.gz</tt>) have an "extra" extension.
      # Classes in the <tt>IMW::Files</tt> module should define a
      # class method <tt>extname</tt> which returns the their full
      # extension.
      def find_extname
        self.class.respond_to?(:extname) ? self.class.extname(@path) : ::File.extname(@path)
      end

      public

      # Is this file on the local machine (the scheme of the file's URI is nil or 
      def local?
        uri.host == 'file' || uri.host.nil?
      end

      # Is this file on a remote machine?
      def remot?
        (! local?)
      end
      
      # Is there a real file at the path of this File?  Will attempt
      # to open files online too to check.
      def exist?
        if local?
          ::File.exist?(@path) ? true : false
        else
          begin
            open(uri)
          rescue SocketError
            false
          end
        end
      end

      # Delete this file.
      def rm!
        raise IMW::PathError.new("cannot delete remote file #{uri}")     unless local?
        raise IMW::PathError.new("cannot delete #{uri}, doesn't exist!") unless exist?
        FileUtils.rm @path
      end

      # Copy this file to +path+.
      def cp path
        raise IMW::PathError.new("cannot copy from #{@path}, doesn't exist!") unless exist?
        if local?
          FileUtils.cp @path,path
        else
          # FIXME better way to do this?
          File.open(path,'w') { |f| f.write(open(uri)).read }
        end
        self.class.new(path)
      end

      # Copy this file to +dir+.
      def cp_to_dir dir
        cp File.join(File.expand_path(dir),basename)
      end

      # Move this file to +path+.
      def mv path
        raise IMW::PathError.new("cannot move from #{@path}, doesn't exist!") unless exist?
        if local?
          FileUtils.mv @path,path
        else
          # FIXME better way to do this?
          File.open(path,'w') { |f| f.write(open(uri)).read }
        end
        self.class.new(path)
      end

      # Move this file to +dir+.
      def mv_to_dir dir
        mv File.join(File.expand_path(dir),basename)
      end
        
    end
  end
end


