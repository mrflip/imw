#
# h2. spec/imw/model/directory_spec.rb -- spec for directories
#
# == About
#
# Defines an RSpec Matcher for matching the contents of a directory.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'set'

require 'imw/utils/extensions/find'

require 'rubygems'
require 'spec'

module Spec
  module Matchers
    module IMW

      # Checks that files in a +target+ directory match those in the
      # +expected+ directory.
      class DirectoryContentsMatcher

        private
        def initialize dir
          @dir = File.expand_path(dir)
          @dir_files = Find.files_relative_to_directory(@dir).to_set
        end

        # Pretty print a set of files.
        def format_files_for_printing files
          files.to_a.join("\n\t")
        end

        public
        def matches? target
          @target = target
          @target_files = Find.files_relative_to_directory(@target).to_set
          @target_files == @dir_files
        end

        def failure_message
          files_missing_from_dir = format_files_for_printing(@target_files - @dir_files)
          files_missing_from_target = format_files_for_printing(@dir_files - @target_files)
          files_in_common = format_files_for_printing(@dir_files & @target_files)
          "expected files in #{@dir} and #{@target} to be identical.\n\nfiles missing from #{@dir}:\n\t#{files_missing_from_dir}\n\nfiles missing from #{@target}:\n\t#{files_missing_from_target}\n\nfiles in common:\n\t#{files_in_common}"
        end

        def negative_failure_message
          "expected files in #{@dir} and #{@target} to be different"
        end
      end
          
      def contain_files_matching_directory dir
        DirectoryContentsMatcher.new(dir)
      end

    end
  end
end

# puts "#{File.basename(__FILE__)}: You brandish your Monkeywrench menacingly at the approaching file-globber; it remains uncowed." # at bottom
