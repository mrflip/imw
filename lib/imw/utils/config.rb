#
# h2. lib/imw/utils/config.rb -- configuration parsing
#
# == About
#
# This Config module defined here is responsible for parsing
# configuration files into useful data structures.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'yaml'
require 'imw/model/directory'

module IMW

  module Config
    # The `etc/directories.yaml' file contains path information for
    # IMW directories in a format that needs to be interpreted here.
    # See the documentation for that file for complete details.
    #
    # In short, directories with a leading '/' are resolved relative
    # to the root of the local filesystem and directories without a
    # leading '/' are resolved relative to the IMW_ROOT which is
    # declared either as an environment variable or in the
    # `directories.yaml' file itself.
    #
    # Directories with a leading protocol statement (ssh:, ftp:, etc.)
    # must be suitably interpreted as well...

    # The `raw_directories' gotten from the configuration file will
    # have to be interpreted properly into Directories
    raw_directories = YAML::load_file(File.expand_path(File.dirname(__FILE__) + "/../../../etc/directories.yaml"))
    Directories = {}

    # find the IMW_ROOT -- environment variable takes precedence over
    # value in configuration file!
    if ENV['IMW_ROOT'] then
      imw_root = File.expand_path(ENV['IMW_ROOT'])
    else
      imw_root = File.expand_path(raw_directories['IMW_ROOT'])
    end
    if !imw_root then
      raise "No root directory for IMW specified!  Set `IMW_ROOT' environment variable or edit etc/directories.yaml"
    else
      Directories[:imw_root] = imw_root
    end


    # Start interpreting the directories (this should be written more
    # cleverly to allow for the structure of the directories.yaml file
    # to be changed...)
    Directories[:ripd] = IMW::Directory.new(raw_directories['workflow']['ripd'])
    Directories[:xtrd] = IMW::Directory.new(raw_directories['workflow']['xtrd'])
    Directories[:mungd] = IMW::Directory.new(raw_directories['workflow']['mungd'])
    Directories[:fixd] = IMW::Directory.new(raw_directories['workflow']['fixd'])
    Directories[:pkgd] = IMW::Directory.new(raw_directories['workflow']['pkgd'])
    Directories[:dump] = IMW::Directory.new(raw_directories['workflow']['dump'])
    Directories[:process] = IMW::Directory.new(raw_directories['process'])
    Directories[:data] = IMW::Directory.new(raw_directories['data'])

    # Here there needs to be section which parses the `taxonomy'
    # section of the `etc/directories.yaml' file to deal with
    # per-category exceptions to the directory rules outlined above.

    # Some aliases for yes/no
    Yeses = ['Yes','YES','yes','Y','y']
    Nos = ['No','NO','no','N','n']
    
  end

end



# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
