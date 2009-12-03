#
# h2. spec/matchers/archive_contents_matcher.rb -- matches contents of archive to disk
#
# == About
#
# An RSpec matcher which tests that an archive of files has the same
# contents as various paths on disk.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'find'

module Spec
  module Matchers
    module IMW

      # Match the contents of the archive against files or directories
      # in +paths+.
      #
      # Options include:
      # 
      # <tt>:relative_to</tt>:: a leading path which will be stripped
      # from all +paths+ before comparison with the contents of the
      # directory.
      class ArchiveContentsMatchPaths

        private
        def initialize paths,opts = {}
          opts.reverse_merge!({:relative_to => nil})
          paths = [paths] if paths.class == String
          @paths = paths
          @relative_to = opts[:relative_to]
          find_paths_contents
        end

        def find_paths_contents
          # find all the files
          contents = []
          @paths.each do |path|
            path = File.expand_path path
            if File.file? path then
              contents << path
            elsif File.directory? path then
              contents += Find.files_in_directory(path)
            end
          end

          # strip leading path
          contents.map! do |path|
            # the +1 is because we want a relative path
            path = path[@relative_to.length + 1,path.size]
          end

          @paths_contents = contents.to_set
        end

        def pretty_print set
          set.to_a.join("\n\t")
        end
        
        public
        def matches? archive
          @archive = archive
          @archive_contents = @archive.contents.to_set
          @archive_contents == @paths_contents
        end

        def failure_message
          missing_from_archive = "missing from archive:\n\t#{pretty_print(@paths_contents - @archive_contents)}\n"
          missing_from_paths = "missing from paths:\n\t#{pretty_print(@archive_contents - @paths_contents)}\n"
          common = "common to both:\n\t#{pretty_print(@archive_contents & @paths_contents)}\n"
          "expected contents of archive (#{@archive.path}) and paths (#{@paths.join(", ")}) to be identical.\n#{missing_from_archive}\n#{missing_from_paths}\n#{common}"
        end

        def negative_failure_message
          "expected contents of archive (#{@archive.path}) and paths (#{@paths.join(", ")}) to differ."
        end
        
      end

      # Invokes the matcher <tt>Spec::Matchers::IMW::ArchiveContentsMatchPaths
      def contain_paths_like paths, opts = {}
        ArchiveContentsMatchPaths.new(paths,opts)
      end
      
    end
  end
end

# puts "#{File.basename(__FILE__)}: An archive is something that is bigger on the inside than it is on the outside." # at bottom
