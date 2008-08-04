#
# h2. lib/imw/workflow/rip/disk.rb -- ripping data from local disk
#
# == About
#
# Contains methods for ripping data from the local disk to the
# appropriate source directory.
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
  module Workflow
    module Rip

      # Copies data from +paths+ to the <tt>:ripd</tt> directory for
      # this source, setting the +source+ attribute to "local".
      #
      # +paths+ can be a collection of files or directories (which
      # will be recursively copied).
      #
      # If called without a block, files will be copied from their
      # source directory to this source's <tt>:ripd</tt> directory and
      # named with their basenames, without any further hierarchical
      # directory structure:
      #
      #   source.rip_from_paths("/path/to/first/file.txt", "/different/path/to/second/thing.dat")
      #
      # will result in the files <tt>file.txt</tt> and
      # <tt>thing.dat</tt> in this source's <tt>:ripd</tt>.
      #
      # If called with a block, then given the path of the original
      # file, the block must return a string representing the path of
      # the copy, relative to the <tt>:ripd</tt> directory of this
      # source.  If the block returns +nil+, then the file will not be
      # copied:
      #
      #   source.rip_from_paths("/path/to/file.txt", "/path/to/second/thing.dat", "/path/to/third.html") do |file|
      #     case File.extname file
      #     when ".txt"
      #       File.join("txt",file)
      #     when ".dat"
      #       File.join("dat",file)
      #     else
      #       nil
      #     end
      #   end
      #
      # will result in the files <tt>txt/file.txt</tt> and
      # <tt>dat/thing.dat</tt> in the <tt>:ripd</tt> directory for
      # this source.
      #
      # Whether or not a block is given, files will not be
      # overwritten; the filenames will be made unique by appending a
      # numeric suffix a la +wget+, i.e. - <tt>common_filename.txt</tt> would
      # become <tt>common_filename.txt.1</tt> and so on (see
      # <tt>File.uniquify</tt>).
      def self.rip_from_paths *paths
        files = paths.flatten.map {|path| Find.files_in_directory(path) }.flatten
        @source = "local"
        files.each do |file|
          # use the basename of the file unless given a block
          filename = File.join(path_to(:ripd), (block_given? ? yield(file) : File.basename(file)))
          filename or next
          File.uniquify filename # ensure we don't clobber existing files
          FileUtils.cp file, filename
        end
      end

    end
  end
end

# puts "#{File.basename(__FILE__)}: You gingerly dangle your Monkeywrench over the maelstrom of spinning platters and extract precisely the one you were interested in." # at bottom
