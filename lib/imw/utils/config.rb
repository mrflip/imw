#
# h2. lib/imw/utils/config.rb -- configuration parsing
#
# == About
#
# IMW looks for configuration settings in the following places, in
# order of increasing precedence:
#
#   1. Settings defined in this file as Ruby objects.
#
#   2. From the <tt>etc/imwrc</tt> file in the IMW root directory.
#
#   3. From the <tt>.imwrc</tt> file in the user's home directory (the
#      filename can be changed; see
#      <tt>IMW::Config::USER_CONFIG_FILE_BASENAME</tt>).
#
#   4. From the file defined by the environment variable +IMWRC+ (the
#      value can be changed; see
#      <tt>IMW::Config::USER_CONFIG_FILE_ENV_VARIABLE</tt>
#
# Settings not found in one configuration location will be searched
# for in locations of lesser precedence.
#
# *Note:* configuration files are _currently_ meant to by plain Ruby code that
# will be directly executed.  Eventually, they are meant to be
# replaced by YAML files that will be parsed by IMW.
#
# Relevant settings include
#
#   * interfaces with external programs (+tar+, +wget+, &c.)
#   * paths to directories where IMW reads/writes files
#
# For more detailed information, read the code of this file or read
# the example configuration file provided at <tt>etc/imwrc</tt>.
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'rubygems'
require 'yaml'

module IMW

  module Config

    ################################################################
    ## Find all the external configuration settings
    ################################################################
    private
    # Returns the root of the IMW source base.
    def self.imw_root
      File.join(File.dirname(__FILE__), '../../..')
    end

    # Returns the default configuration filename, <tt>etc/imwrc</tt>
    # in the IMW root directory.
    def self.default_config_filename
      File.join(imw_root, 'etc', 'imwrc.rb')
    end

    # we require the default configuration file
    eval(File.open(default_config_filename).read) if File.exist? default_config_filename

    # The basename of the file looked for in the user's home directory
    # for configuration settings.
    USER_CONFIG_FILE_BASENAME = ".imwrc" unless defined? USER_CONFIG_FILE_BASENAME

    # Returns the path to the configuration file in the home directory
    # of each user.
    def self.user_home_config_filename
      File.join(ENV['HOME'], USER_CONFIG_FILE_BASENAME)
    end

    # we now require the configuration file in the home directory of
    # the user
    eval(File.open(user_home_config_filename).read) if File.exist? user_home_config_filename

    # The environment variable checked for a file with configuration
    # settings.
    USER_CONFIG_FILE_ENV_VARIABLE = "IMWRC" unless defined? USER_CONFIG_FILE_ENV_VARIABLE

    # we now require the configuration file pointed at by the user's
    # environment variable
    eval(File.open(USER_CONFIG_FILE_ENV_VARIABLE).read) if File.exist? USER_CONFIG_FILE_ENV_VARIABLE

    ################################################################
    ## Now make settings here if they're not defined already in the above
    ################################################################
    
    # Paths to external programs.
    IMW::EXTERNAL_PROGRAMS = {
      :tar => "tar",
      :rar => "rar",
      :zip => "zip",
      :unzip => "unzip",
      :gzip => "gzip",
      :bzip2 => "bzip2",
      :wget => "wget"
    } unless defined? IMW::EXTERNAL_PROGRAMS

    # Directories where IMW will write and look for files.
    IMW::DIRECTORIES = {
      :sources => File.expand_path("~/imw/pool/sources"),
      :datasets => File.expand_path("~/imw/pool/datasets"),
      
      :data => File.expand_path("~/imw/data"),
      :ripd => File.expand_path("~/imw/data/ripd"),
      :xtrd => File.expand_path("~/imw/data/xtrd"),
      :prsd => File.expand_path("~/imw/data/prsd"),
      :mungd => File.expand_path("~/imw/data/mungd"),
      :fixd => File.expand_path("~/imw/data/fixd"),
      :pkgd => File.expand_path("~/imw/data/pkgd"),

      :dump => "/tmp/imw"
    } unless defined? IMW::DIRECTORIES


    module Files
      # Correspondence between extensions and file types.  Used by
      # <tt>IMW::Files.identify</tt> to identify files based on known
      # extensions.
      #
      # File type strings should be stripped of the leading
      # <tt>IMW::Files</tt> prefix, i.e. - the file object
      # <tt>IMW::Files::Bz2</tt> should be referenced by the string
      # <tt>"Bz2"</tt>.
      EXTENSIONS = {
        ".bz2" => "Bz2",
        ".gz" => "Gz",
        ".tar.bz2" => "TarBz2",
        ".tbz2" => "TarBz2",
        ".tar.gz" => "TarGz",
        ".tgz" => "TarGz",
        ".rar" => "Rar",
        ".zip" => "Zip",
        ".txt" => "Text",
        ".ascii" => "Text",
        ".csv" => "Csv",
        ".xml" => "Xml",
        ".html" => "Html",
        ".yaml" => "Yaml",
        ".yml" => "Yaml"
      } unless defined? IMW::Files::EXTENSIONS
    end
  end
end

# puts "#{File.basename(__FILE__)}: You carefully adjust the settings on your Monkeywrench.  Beware, glob-monsters!" # at bottom
