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
require 'imw/utils/extensions/hash'

module Find

  # Returns a list of paths relative to +directory+ of the files (and
  # only the files) it contains.
  #
  # Options include:
  #
  # <tt>:include</tt>:: a regular expression that the relative part of
  #                     each path must match.
  #
  # <tt>:exclude</tt>:: a regular expression that the relative part of
  #                     each path must not match.
  def self.files_relative_to_directory directory, opts = {}
    opts.reverse_merge!({:include => nil, :exclude => nil})
    directory = File.expand_path directory
    files = []
    Find.find(directory) do |path|
      unless File.directory?(path)
        abs_path = File.expand_path(path)
        # the +1 is there because we want a relative path
        rel_path = abs_path.slice(directory.length + 1,abs_path.length)
        # FIXME this is a stupid way of testing both regexen
        if opts[:include] then
          matches = opts[:include].match(rel_path)
        elsif opts[:exclude] then
          matches = opts[:exclude].match(rel_path)
        elsif opts[:include] && opts[:exclude] then
          matches = opts[:include].match(rel_path) && opts[:exclude].match(rel_path)
        else
          matches = true
        end
        files << rel_path if matches
      end
      files
    end
    files
  end

  # Returns a list of absolute paths in +directory+ of the files (and
  # only the files) it contains.
  # 
  # Options include:
  #
  # <tt>:include</tt>:: a regular expression that each path must
  #                     match.
  #
  # <tt>:exclude</tt>:: a regular expression that each path must not
  #                     match.
  def self.files_in_directory directory, opts = {}
    opts.reverse_merge!({:include => nil, :exclude => nil})
    directory = File.expand_path directory
    files = []
    Find.find(directory) do |path|
      unless File.directory?(path)
        # FIXME this is a stupid way of testing both regexen
        if opts[:include] then
          matches = opts[:include].match(path)
        elsif opts[:exclude] then
          matches = opts[:exclude].match(path)
        elsif opts[:include] && opts[:exclude] then
          matches = opts[:include].match(path) && opts[:exclude].match(path)
        else
          matches = true
        end
        files << path if matches
      end
    end
    files
  end

end

# puts "#{File.basename(__FILE__)}: Wise man say: it is easier to find a Monkeywrench in a haystack than a needle.  Likely this is because, you know, wrenches are large and needles are, well, small." # at bottom
