#-*- mode: ruby -*-
#
# h2. etc/imwrc -- default site-wide imw configuration file
#
# == About
#
# This file contains the site-wide configuration settings for this
# installation of the Infinite Monkeywrench.  Settings here override
# the defaults in <tt>lib/imw/utils/config.rb</tt> (see the
# documentation for that file for more detail on the variables that
# can be configured here) but will in turn be overwritten by settings
# in the <tt>~/.imwrc</tt> file in each user's directory (though the
# location of this file can be customized).
#
# At the present moment, all settings are stored as plain Ruby files
# (though they may lack the <tt>.rb</tt> extension).  As the IMW
# develops, these will be replaced by YAML files which will be parsed
# by <tt>lib/imw/utils/config.rb</tt>.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

module IMW
  PATHS = {
    :home       => ENV['HOME'],
    :imw_root   => File.expand_path(File.join(File.dirname(__FILE__), '..')),
    :super_root => File.expand_path(File.join(File.dirname(__FILE__), '../..')),

    # Data processing scripts
    :scripts_root => [:super_root, 'pool'],

    # the imw library
    :imw_bin   => [:imw_root, 'bin'],
    :imw_etc   => [:imw_root, 'etc'],
    :imw_lib   => [:imw_root, 'lib'],

    # Data
    :data_root => [:super_root,  'data'],
    :ripd_root => [:data_root, 'ripd'],
    :rawd_root => [:data_root, 'rawd'],
    :temp_root => [:data_root, 'temp'],
    :fixd_root => [:data_root, 'fixd'],
    :pkgd_root => [:data_root, 'pkgd'],
    :log_root  => [:data_root, 'log'],
  }
  PATHS[:site_root] = [RAILS_ROOT] if defined?(RAILS_ROOT)

  # Default time format.
  STRFTIME_FORMAT = "%Y%m%d-%H%M%S" unless defined? STRFTIME_FORMAT

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
    :log => File.expand_path("~/imw/data/log"),
    :dump => "/tmp/imw",
    :data => File.expand_path("~/imw/data"),
    :rip => File.expand_path("~/imw/data/ripd"),
    :parse => File.expand_path("~/imw/data/prsd"),
    :munge => File.expand_path("~/imw/data/mungd"),
    :fix => File.expand_path("~/imw/data/fixd"),
    :package => File.expand_path("~/imw/data/pkgd")
  } unless defined? ::IMW::DIRECTORIES

  module Files
    # Regular expressions which match pathnames to the name of the
    # appropriate IMW::Files class.
    #
    # File class names should be stripped of the leading
    # <tt>IMW::Files</tt> prefix, i.e. - the file object
    # <tt>IMW::Files::Bz2</tt> should be referenced by the string
    # <tt>"Bz2"</tt>.
    FILE_REGEXPS = {
      /\.bz2$/      => "Bz2",
      /\.gz$/       => "Gz",
      /\.tar\.bz2$/ => "TarBz2",
      /\.tbz2$/     => "TarBz2",
      /\.tar\.gz$/  => "TarGz",
      /\.tgz$/      => "TarGz",
      /\.rar$/      => "Rar",
      /\.zip$/      => "Zip",
      /\.txt$/      => "Text",
      /\.ascii$/    => "Text",
      /\.csv$/      => "Csv",
      /\.tsv$/      => "Tsv",      
      /\.xml$/      => "Xml",
      /\.html$/     => "Html",
      /\.yaml$/     => "Yaml",
      /\.yml$/      => "Yaml"
    } unless defined? ::IMW::Files::FILE_REGEXPS
  end

  # Default settings for uploading datasets to
  # archive.org[http://archive.org].
  ARCHIVE_ORG_UPLOAD_SETTINGS = {
    :server => "items-uploads.archive.org",
    :collection => "Infochimps",
    :mediatype => "Data"
  }


end


