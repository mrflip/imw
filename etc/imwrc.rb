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

  DEFAULT_PATHS = {
    :home         => ENV['HOME'],
    :data_root    => "/var/lib/imw",
    :log_root     => "/var/log/imw",
    :scripts_root => "/usr/share/imw",
    :tmp_root     => "/tmp/imw",

    # the imw library
    :imw_root  => File.expand_path(File.dirname(__FILE__) + "/.."),
    :imw_bin   => [:imw_root, 'bin'],
    :imw_etc   => [:imw_root, 'etc'],
    :imw_lib   => [:imw_root, 'lib'],

    # workflow
    :ripd_root  => [:data_root, 'ripd'],
    :peeld_root => [:data_root, 'peeld'],
    :mungd_root => [:data_root, 'mungd'],
    :temp_root  => [:data_root, 'temp'],
    :fixd_root  => [:data_root, 'fixd'],
    :pkgd_root  => [:data_root, 'pkgd']
  }
  defined?(PATHS) ? PATHS.reverse_merge!(DEFAULT_PATHS) : PATHS = DEFAULT_PATHS

  # Default time format.
  STRFTIME_FORMAT = "%Y%m%d-%H%M%S" unless defined? STRFTIME_FORMAT

  # Paths to external programs used by IMW.
  DEFAULT_EXTERNAL_PROGRAMS = {
    :tar   => "tar",
    :rar   => "rar",
    :zip   => "zip",
    :unzip => "unzip",
    :gzip  => "gzip",
    :bzip2 => "bzip2",
    :wget  => "wget"
  }
  defined?(::IMW::EXTERNAL_PROGRAMS) ? ::IMW::EXTERNAL_PROGRAMS.reverse_merge!(DEFAULT_EXTERNAL_PROGRAMS) : ::IMW::EXTERNAL_PROGRAMS = DEFAULT_EXTERNAL_PROGRAMS

  module Files
    # Regular expressions which match pathnames to the name of the
    # appropriate IMW::Files class.
    #
    # File class names should be stripped of the leading
    # <tt>IMW::Files</tt> prefix, i.e. - the file object
    # <tt>IMW::Files::Bz2</tt> should be referenced by the string
    # <tt>"Bz2"</tt>.
    FILE_REGEXPS = [] unless defined? ::IMW::Files::FILE_REGEXPS
  end

end


