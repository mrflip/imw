#
# h2. lib/imw/model/files/archive.rb -- describes archives of files
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

require 'fileutils'

require 'imw/utils'

module IMW

  module Files

    module Archive

      attr_reader :archive

      # Create this archive containing the given +files+.
      #
      # Options:
      # <tt>:force</tt> (false):: overwrite any existing archive at this path.
      def create files, opts = {}
        opts.reverse_merge!({:force => false})
        raise IMW::Error.new("An archive already exists at #{@path}.") if exist? and not opts[:force]

        files = [files] if files.class == String

        FileUtils.cd(@dirname)
        command = ([IMW::EXTERNAL_PROGRAMS[@archive[:program]],@archive[:create_flags],@basename] + files).join ' '
        IMW.system(command)
      end

      # Append to this archive the given +files+.
      def append files
        files = [files] if files.class == String
        
        FileUtils.cd(@dirname)
        command = ([IMW::EXTERNAL_PROGRAMS[@archive[:program]],@archive[:append_flags],@basename] + files).join ' '
        IMW.system(command)
      end

      # Extract the files from this archive to its directory.
      def extract
        FileUtils.cd(@dirname)

        program = @archive[:unarchiving_program] || @archive[:program]
        command = [IMW::EXTERNAL_PROGRAMS[program],@archive[:extract_flags],@basename].join ' '
        IMW.system(command)
      end

      # Return a (sorted) list of contents in this archive.
      def contents
        FileUtils.cd(@dirname)

        program = @archive[:unarchiving_program] || @archive[:program]        
        command = [IMW::EXTERNAL_PROGRAMS[program],@archive[:list_flags],@basename].join ' '
        # run the command first through `IMW.system' so we can ensure
        # it exited cleanly before we try to capture its output
        IMW.system(command)
        output = `#{command}`
        archive_contents_string_to_array(output)
      end

      # Parse and format the output from the archive program's "list"
      # command into an array of filenames.
      #
      # An including class can customize this method to match the
      # output from the archiving program of that class.
      def archive_contents_string_to_array string
        string.split("\n").sort
      end
      
    end
    
  end
    
end

# puts "#{File.basename(__FILE__)}: Put it all in one place so that when something goes wrong you'll know it immediately.  You'll regret it, but at least you'll know." # at bottom
