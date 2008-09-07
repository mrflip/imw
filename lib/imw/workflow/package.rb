#
# h2. lib/imw/workflow/package.rb -- methods for packaging datasets
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/tar'
require 'imw/model/files/zip'

module IMW

  module Package

    # Package the contents of +dir_to_package+ as a +tar+ archive and
    # put it in +dir_for_package+.
    def self.to_tar dir_for_package, dir_to_package
      dir_for_package = File.expand_path(dir_for_package)
      dir_to_package = File.expand_path(dir_to_package)

      tar = IMW::Files::Tar.new(File.join(dir_for_package,File.basename(dir_to_package) + ".tar"))
      tar.create(dir_to_package)
      tar
    end

    # Package the contents of +dir_to_package+ as a
    # <tt>tar.bz2</tt> archive and put it in +dir_for_package+.
    def self.to_tarbz2 dir_for_package, dir_to_package
      dir_for_package = File.expand_path(dir_for_package)
      dir_to_package = File.expand_path(dir_to_package)

      tar = IMW::Files::Tar.new(File.join(dir_for_package,File.basename(dir_to_package) + ".tar"))
      tar.create(dir_to_package)
      tar.compress!(:bzip2)
    end

    # Package the contents of +dir_to_package+ as a
    # <tt>tar.gz</tt> archive and put it in +dir_for_package+.
    def self.to_targz dir_for_package, dir_to_package
      dir_for_package = File.expand_path(dir_for_package)
      dir_to_package = File.expand_path(dir_to_package)

      tar = IMW::Files::Tar.new(File.join(dir_for_package,File.basename(dir_to_package) + ".tar"))
      tar.create(dir_to_package)
      tar.compress!(:gzip)
    end

    # Package the contents of +dir_to_package+ as a
    # <tt>zip</tt> archive and put it in +dir_for_package+.
    def self.to_zip dir_for_package, dir_to_package
      dir_for_package = File.expand_path(dir_for_package)
      dir_to_package = File.expand_path(dir_to_package)

      zip = IMW::Files::Zip.new(File.join(dir_for_package,File.basename(dir_to_package) + ".zip"))
      zip.create(dir_to_package)
      zip
    end
  end
end

# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
