#
# h2. lib/imw/model/archive.rb -- classes for manipulating various archive formats
#
# == About
#
# Module used for making an object act like an archive of files.  The
# including object must define a class variable +archiving+ which must
# be a hash with the following keys:
#
# <tt>:type</tt> (required):: a Symbol defining a type of archive (likely one of of <tt>:tar</tt>, <tt>:rar</tt>, or <tt>:zip</tt>.
# <tt>:program</tt>:: a String defining the program to be used.  If none is provided, the program is chosen from IMW::EXTERNAL_PROGRAMS according to the <tt>:type</tt> of the archive
# <tt>:create_flags</tt> (required):: a String containing the flags to use when creating an archive
# <tt>:extract_flags</tt> (required):: a String containing the flags to use when extracting an archive or a Symbol naming an instance method which takes a directory as an argument and returns a String containing the flags
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'rubygems'
require 'activesupport'

require 'imw/utils'
require 'imw/utils/core_extensions'

module IMW

  module Archive

    # Include files into this archive.  If the archive is empty then
    # create it first.
    #
    # Options:
    # <tt>:del_orig_files</tt> (false):: delete original copies of files after storing them in this archive
    def self.create files, opts = {}
      opts.reverse_merge!({:del_orig_files => false})
      paths = files.map { |file| file.class == String ? File.expand_path(file) : File.expand_path(file.path) }
      program = self.archiving[:program] || IMW::EXTERNAL_PROGRAMS[self.archiving[:type]]
      flags = self.archiving[:create_flags]
      command =  program + ' ' + flags + ' ' + paths
      IMW.system(command)
      if opts[:del_orig_files] then files.each {|file| FileUtils.rm(file)} end
    end

    # Extract files from this archive.
    # 
    # Options:
    # <tt>:del_archive</tt> (false):: delete the archive after extracting files
    def self.extract directory = nil, opts = {}
      opts.reverse_merge!({:del_archive => false})
      program = self.archiving[:program] || IMW::EXTERNAL_PROGRAMS[self.archiving[:type]]
      flags = self.archiving[:extract_flags]
      if flags.class == Symbol then flags = self.send(flags,directory) end # customized flags on a per extraction basis
      command =  program + ' ' + flags + ' ' + paths
      IMW.system(command)
      if opts[:del_archive] then FileUtils.rm(self.path) end
    end
    
  end

end


# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
