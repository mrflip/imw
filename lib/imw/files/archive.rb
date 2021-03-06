#
# h2. lib/imw/files/archive.rb -- describes archives of files
#
# == About
#
# Module for describing known archive types.  An including archive
# type's class must define an instance variable +archive+ which is a
# hash with the following required keys:
#
# <tt>:program</tt>:: a symbol naming the program to be used.  It
# should match one of the symbols in <tt>IMW::EXTERNAL_PROGRAMS</tt>
# 
# <tt>:create_flags</tt>:: a string of flags to pass to the archiving
# program when creating the archive
# 
# <tt>:append_flags</tt>:: a string of flags to pass to the archiving
# program when appending files to the archive
# 
# <tt>:extract_flags</tt>:: a string of flags to pass to the archiving
# program when extracting the archive
# 
# <tt>:list_flags</tt>:: a string of flags to pass to the archiving
# program when listing the archive's contents
#
# THe +archive+ hash may also contain the entry:
#
# <tt>:unarchiving_program</tt>:: a symbol naming the program to be
# used to list/extract the archive.  Useful only if this program
# differs from the program used to create the archive in the first
# place (i.e. - zip & unzip).
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
# puts "#{File.basename(__FILE__)}: Put it all in one place so that when something goes wrong you'll know it immediately.  You'll regret it, but at least you'll know." # at bottom
module IMW
  module Files

    module BasicFile

      # Is this file an archive?
      def archive?
        false
      end
    end
    
    module Archive

      attr_reader :archive

      # Is this file an archive?
      def archive?
        true
      end

      public
      # Create this archive containing the given +paths+.
      def create *paths
        raise IMW::Error.new("Cannot create an archive of type #{@extname}") unless @archive[:create_flags]
        IMW.system IMW::EXTERNAL_PROGRAMS[@archive[:program]], @archive[:create_flags], @path, *paths.flatten
        self
      end

      # Append to this archive the given +paths+.
      def append *paths
        raise IMW::Error.new("Cannot append to an archive of type #{@archive[:program]}.") unless @archive[:append_flags]
        IMW.system IMW::EXTERNAL_PROGRAMS[@archive[:program]], @archive[:append_flags], @path, *paths.flatten
        self
      end

      # Extract the files from this archive to the current directory.
      def extract
        raise IMW::Error.new("Cannot extract, #{@path} does not exist") unless exist?
        program = (@archive[:unarchiving_program] or @archive[:program])
        IMW.system IMW::EXTERNAL_PROGRAMS[program], @archive[:extract_flags], @path
      end

      # Return a (sorted) list of contents in this archive.
      def contents
        raise IMW::Error.new("Cannot list contents, #{path} does not exist") unless exist?
        program = (@archive[:unarchiving_program] or @archive[:program])
        # FIXME this needs to be more robust        
        command = [IMW::EXTERNAL_PROGRAMS[program], @archive[:list_flags], path.gsub(' ', '\ ')].join ' '
        output  = `#{command}`
        archive_contents_string_to_array(output)
      end

      # Parse and format the output from the archive program's "list"
      # command into an array of filenames.
      #
      # An including class can override this method to match the
      # output from the archiving program of that class.
      def archive_contents_string_to_array string
        string.split("\n")
      end
    end
  end
end


