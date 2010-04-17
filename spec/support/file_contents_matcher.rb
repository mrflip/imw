#
# h2. spec/imw/matchers/file_contents_matcher.rb -- matches contents of two files
#
# == About
#
# An RSpec matcher which tests that two files have the same contents
# on disk.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'ftools'

module Spec
  module Matchers
    module IMW

      class FileContentsMatcher
        def initialize orig
          @orig = File.expand_path orig
        end

        def matches? copy
          @copy = File.expand_path copy
          File.compare(@orig,@copy)
        end

        def failure_message
          "files #{@orig} and #{@copy} are different"
        end

        def negative_failure_message
          "expected files #{@orig} and #{@copy} to differ"
        end
      end

      # Matches the contents of one file against another using
      # File.compare.
      def have_contents_matching_those_of path
        FileContentsMatcher.new(path)
      end
      
    end
  end
end

# puts "#{File.basename(__FILE__)}: From far away, the folders appear the same; from up close, they are different." # at bottom
