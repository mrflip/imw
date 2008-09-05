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
    raise IMW::PathError.new("#{directory} is not a valid directory") unless File.directory? directory
    files = []
    Find.find(directory) do |path|
      if File.exist?(path) && File.file?(path)
        abs_path = File.expand_path(path)
        # the +1 is there because we want a relative path
        rel_path = abs_path.slice(directory.length + 1,abs_path.length)
        # FIXME this is a stupid way of testing both regexen
        if opts[:include] && !opts[:exclude] then
          should_be_returned = opts[:include].match(rel_path)
        elsif !opts[:include] && opts[:exclude] then
          should_be_returned = !opts[:exclude].match(rel_path)
        elsif opts[:include] && opts[:exclude] then
          should_be_returned = opts[:include].match(rel_path) && (!opts[:exclude].match(rel_path))
        else
          should_be_returned = true
        end
        files << rel_path if should_be_returned
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
    raise IMW::PathError.new("#{directory} is not a valid directory") unless File.directory? directory    
    files = []
    Find.find(directory) do |path|
      if File.exist?(path) && File.file?(path)
        # FIXME this is a stupid way of testing both regexen
        if opts[:include] && !opts[:exclude] then
          should_be_returned = opts[:include].match(path)
        elsif !opts[:include] && opts[:exclude] then
          should_be_returned = !opts[:exclude].match(path)
        elsif opts[:include] && opts[:exclude] then
          should_be_returned = opts[:include].match(path) && !opts[:exclude].match(path)
        else
          should_be_returned = true
        end
        files << path if should_be_returned
      end
    end
    files
  end

  # Scan recursively through +directory+ and return a list of all
  # unique uniqnames corresponding to files in +dir+.
  def self.uniqnames_in_directory directory
    files_in_directory(directory).map {|path| File.uniqname path}.uniq
  end
  
end

# puts "#{File.basename(__FILE__)}: Wise man say: it is easier to find a Monkeywrench in a haystack than a needle.  Likely this is because, you know, wrenches are large and needles are, well, small." # at bottom
