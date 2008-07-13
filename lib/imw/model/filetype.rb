#
# h2. lib/imw/model/filetype -- base class for file types
#
# == About
#
# Defines a base class for specific filetype classes to subclass from
# and also provides some modules implementing shared functionality
# (compression, archives, etc.)
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/utils/error'
require 'imw/utils/core_extensions'

module IMW

  # A base class from which to subclass classes for particular
  # filetpyes.
  class Filetype

    attr_reader :path, :dirname, :basename, :extension

    def initialize(path)
      path = File.expand_path path
      raise IMW::PathError.new "#{path} is a directory" if File.directory? path
      @path = path      
      @dirname = File.dirname @path
      @basename = File.basename @path
      @extname = File.extname @path
    end

    def exist?
      File.exist? @path ? true : false
    end
    
  end

  module Archive

    # Include files into this archive.  If the archive is empty then
    # create it first.
    def self.include(program, flags, files)
      paths = files.map { |file| file.class == String ? file : file.path }
      command = program + flags + paths
      system(command)
      raise IMW::SystemCallError.new "Couldn't include files in archive. (#{command})" unless $?.success?
      

end

# puts "#{File.basename(__FILE__)}: At the very bottom of the tower, wedged between a small boulder and a rotting log you see a weathered manilla file folder.  The writing on the tab is too faded to make out." # at bottom
