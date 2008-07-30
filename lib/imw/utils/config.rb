#
# h2. lib/imw/utils/config.rb -- configuration parsing
#
# == About
#
# This file defines constants that describe the external utilties IMW
# depends upon, the directories it is allowed to write in, the file
# extensions it knows about, &c.
#
# Right now, this information is simply coded as Ruby structures.
# Eventually, this will be replaced by a module which parses YAML
# configuration files to construct the same objects.  As IMW is in
# flux, hard-coding in the constants is a little easier for now.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

module IMW

  # Paths to external programs.
  EXTERNAL_PROGRAMS = {
    :tar => "tar",
    :rar => "rar",
    :zip => "zip",
    :unzip => "unzip",
    :gzip => "gzip",
    :bzip2 => "bzip2",
    :wget => "wget"
  }

  # Directories where IMW will write files.
  DIRECTORIES = {
    :root => "/home/dhruv/projects/infochimps/imw",
    :ripd => "/home/dhruv/projects/infochimps/data/ripd",
    :xtrd => "/home/dhruv/projects/infochimps/data/xtrd",
    :mungd => "/home/dhruv/projects/infochimps/data/mungd",
    :fixd => "/home/dhruv/projects/infochimps/data/fixd",
    :pkgd => "/home/dhruv/projects/infochimps/data/pkgd",
    :dump => "/tmp/imw"
  }

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
      ".html" => "Html"
    }
  end

end

# puts "#{File.basename(__FILE__)}: You carefully adjust the settings on your Monkeywrench.  Beware, glob-monsters!" # at bottom
