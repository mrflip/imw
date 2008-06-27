#
# h2. lib/imw/workflow/extract.rb -- tools for extracting files into YAML
#
# == About
#
# This file contains methods for processing files into YAML that are
# independent of the format of the file.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/workflow/extract/flat'
require 'find'

module IMW
  module Workflow
    module Extract

      # Finds all archives in this source's <tt>:ripd</tt> directory
      # and extracts them.
      #
      # Supported archive types include <tt>tar</tt>, <tt>bz2</tt>,
      # <tt>gz</tt>, <tt>rar</tt> and <tt>zip</tt>.
      #
      # Options (with their default values in parentheses) include:
      # <tt>:simulate</tt> (false):: Show what would be done without doing it.
      # <tt>:keep_archives</tt> (false):: Keep archives after extracting files from them.
      # <tt>:verbose</tt> (false):: Print output.
      # <tt>:tar_path</tt> ('tar'):: Path to the Tar program.
      # <tt>:bzip2_path</tt> ('bzip2'):: Path to the bzip2 program.
      # <tt>:gzip_path</tt> ('gzip'):: Path to the gzip program.
      # <tt>:unrar_path</tt> ('unrar'):: Path to the unrar program.
      # <tt>:unzip_path</tt> ('unzip'):: Path to the unzip program.
      def decompress_archives(user_opts={})

        # set default options and update with user options
        options = {:simulate => false, :keep_archives => false, :verbose => false, :tar_path => 'tar', :bzip2_path => 'bzip2', :gzip_path => 'gzip', :unrar_path => 'unrar', :unzip_path => 'unzip'}
        options.update(user_opts)
        
        # find archives
        archives = []
        Find.find(self.path_to(:ripd)) do |path|
          archives << path if File.file?(path) and path =~ /(tar$|bz2$|tar\.bz2$|gz$|tar\.gz$|rar$|zip$)/
        end

        # extract archives
        archives.each do |path|
          Dir.chdir(File.dirname(path))
          archive = File.basename(path)
          flags = []
          if archive =~ /tar$/ then
            flags << 'x'
            flags << 'f'
            flags << 'v' if options[:verbose]
            command = "#{options[:tar_path]} -#{flags.join('')} #{archive}"
            system(command)
            
          elsif archive =~ /bz2$/ then
            true
          elsif archive =~ /tar\.bz2$/ then
            true
          elsif archive =~ /gz$/ then
            true
          elsif archive =~ /tar\.gz$/ then
            true
          elsif archive =~ /rar$/ then
            true
          elsif archive =~ /zip$/ then
            true
          end
      end
      
    end
  end
end


# puts "#{File.basename(__FILE__)}: Why is it that squeezing lemons lets you extract lemonade but squeezing a banana just makes a mess?" # at bottom
