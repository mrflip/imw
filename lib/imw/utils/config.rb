#
# h2. lib/imw/utils/config.rb -- configuration parsing
#
# == About
#
# IMW looks for configuration settings in the following places, in
# order of increasing precedence:
#
#   1. Settings defined directly in this file.
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
# *Note:* configuration files are _currently_ plain Ruby code that
# will be directly evaluated.  Eventually, they will be replaced by
# YAML files that will be parsed by IMW.
#
# Relevant settings include
#
# * interfaces with external programs (+tar+, +wget+, &c.)
# * paths to directories where IMW reads/writes files
# * correspondences between file extensions and IMW file classes
#
# For more detailed information, see the default configuration file,
# <tt>etc/imwrc</tt>.
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

module IMW
  module Config
    # Returns the root of the IMW source base.
    def self.imw_root
      File.join(File.dirname(__FILE__), '../../..')
    end

    # The path to the site IMW configuration file relative to the IMW
    # root.
    SITE_CONFIG_FILE = "etc/imwrc"
    
    # The default path to the user-specific IMW configuration file
    # (will be +expand_path+'ed before use)
    USER_CONFIG_FILE = "~/.imwrc"

    # The default environment variable which points to a
    # configuration file.
    ENV_CONFIG_FILE = "IMWRC"

    # Evaluate the default configuration file
    load File.join(imw_root,SITE_CONFIG_FILE)

    # Evaluate the user-specific config file
    load File.expand_path(USER_CONFIG_FILE)

    # Evaluate the configuration file pointed at by the environment
    # variable
    load(File.expand_path(ENV[ENV_CONFIG_FILE])) if ENV[ENV_CONFIG_FILE] && File.exist?(ENV[ENV_CONFIG_FILE])
  end
end

module IMW

  # Default time format.
  STRFTIME_FORMAT = "%Y%m%dT%H%M%S" unless defined? STRFTIME_FORMAT

  # Paths to external programs used by IMW.
  EXTERNAL_PROGRAMS = {
    :tar => "tar",
    :rar => "rar",
    :zip => "zip",
    :unzip => "unzip",
    :gzip => "gzip",
    :bzip2 => "bzip2",
    :wget => "wget"
  } unless defined? ::IMW::EXTERNAL_PROGRAMS

  # Directories where IMW will write and look for files.
  DIRECTORIES = {
    :instructions => File.expand_path("~/imw/instructions"),
    :log => File.exapnd_path("~imw/data/log"),
    :dump => "/tmp/imw",
    
    :data => File.expand_path("~/imw/data"),
    :rip => File.expand_path("~/imw/data/ripd"),
    :parse => File.expand_path("~/imw/data/prsd"),
    :munge => File.expand_path("~/imw/data/mungd"),
    :fix => File.expand_path("~/imw/data/fixd"),
    :package => File.expand_path("~/imw/data/pkgd")
  } unless defined? ::IMW::DIRECTORIES

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
    } unless defined? ::IMW::Files::EXTENSIONS
  end
end

# puts "#{File.basename(__FILE__)}: You carefully adjust the settings on your Monkeywrench.  Glob-monsters: beware!!" # at bottom
