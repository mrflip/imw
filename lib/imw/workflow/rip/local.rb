#
# h2. lib/imw/workflow/rip/disk.rb -- ripping data from local disk
#
# == About
#
# Contains methods for ripping data from various paths on the local
# disk to a target directory.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'

require 'imw/utils'
require 'imw/utils/extensions/find'

module IMW
  module Rip

    # Copies data from +paths+ to the +target_directory+.
    #
    # +paths+ can be a collection of files or directories (which
    # will be recursively copied).
    #
    # If called without a block, files will be copied to the
    # +target_directory+ and named with their basenames, without any
    # further hierarchical directory structure:
    #
    #   copy_files_to_target("/target/directory","/path/to/first/file.txt", "/different/path/to/second/thing.dat")
    #
    # will result in the files <tt>/target/directory/file.txt</tt>
    # and <tt>/target/directorything.dat</tt>.
    #
    # If called with a block, then given the path of the original
    # file, the block must return a string representing the path of
    # the copy, relative to the +target_directory+.  If the block
    # returns +nil+, then the file will not be copied:
    #
    #   copy_files_to_target("/target/directory", "/path/to/file.txt", "/path/to/second/thing.dat", "/path/to/third.html") do |file|
    #     case File.extname file
    #     when ".txt"
    #       File.join("txt",File.basename file) # put text files in /target/directory/txt
    #     when ".dat"
    #       File.join("dat",File.basename file) # put dat files in /target/directory/dat
    #     else
    #       nil # don't copy any other kinds of files
    #     end
    #   end
    #
    # will result in the files
    # <tt>/target/directory/txt/file.txt</tt> and
    # <tt>/target/directory/dat/thing.dat</tt>.
    #
    # Whether or not a block is given, files will not be
    # overwritten; the filenames will be made unique by appending a
    # numeric suffix a la +wget+, i.e. -
    # <tt>common_filename.txt</tt> would become
    # <tt>common_filename.txt.1</tt> or
    # <tt>common_filename.txt.2</tt> and so on until a non-existing
    # filename was found(see <tt>File.uniquify</tt>).
    def self.copy_files_to_target target_directory, *paths
      target_directory = File.expand_path(target_directory)
      raise IMW::PathError.new("#{target_directory} is not a valid directory") unless File.directory?(target_directory)
      files = paths.flatten.map do |path|
        raise IMW::PathError.new("#{path} does not exist") unless File.exist? path
        File.directory?(path) ? Find.files_in_directory(path) : path
      end
      files.flatten.each do |file|
        # use the basename of the file unless given a block
        basename = (block_given? ? yield(file) : File.basename(file))
        basename or next # if the block returns nil then don't copy this file
        
        filename = File.join(target_directory, basename)
        File.uniquify filename # ensure we don't clobber existing files
        
        FileUtils.mkdir_p(File.dirname(filename)) unless File.exist?(File.dirname(filename)) # ensure the directory will exist
        
        FileUtils.cp file, filename
      end
    end

  end
end

# puts "#{File.basename(__FILE__)}: You gingerly dangle your Monkeywrench over the maelstrom of spinning platters and extract precisely the one you were interested in." # at bottom
