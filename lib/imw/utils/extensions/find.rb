#
# h2. lib/imw/utils/extensions/find.rb -- extensions to find module
#
# == About
#
# Contains a few useful extensions to the Find module in the Standard
# Library.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'find'

module Find

  # Returns a list of paths relative to +directory+ of the files (and
  # only the files) it contains, optionally matching the given
  # +regex+.
  def self.files_relative_to_directory directory, regex = //
    directory = File.expand_path directory
    files = []
    Find.find(directory) do |path|
      unless File.directory?(path)
        abs_path = File.expand_path(path)
        # the +1 is there because we want a relative path
        rel_path = abs_path.slice(directory.length + 1,abs_path.length)
        files << rel_path if regex.match rel_path
      end
    end
    files
  end

  # Returns a list of absolute paths in +directory+ of the files (and
  # only the files) it contains, optionally matching the given
  # +regex+.
  def self.files_in_directory directory, regex = //
    directory = File.expand_path directory
    files = []
    Find.find(directory) do |path|
      unless File.directory?(path)
        files << path if regex.match path
      end
    end
    files
  end

end

# puts "#{File.basename(__FILE__)}: Wise man say: it is easier to find a Monkeywrench in a haystack than a needle.  Likely this is because, you know, wrenches are large and needles are, well, small." # at bottom
