#
# h2. lib/imw/model/files/compressed_files_and_archives.rb -- require farm
#
# == About
#
# Just required all the archive and compressed formats (+tar+, +bz2+,
# &c.)
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom


require 'imw/model/files/tar'
require 'imw/model/files/zip'
require 'imw/model/files/rar'
require 'imw/model/files/targz'
require 'imw/model/files/tarbz2'
require 'imw/model/files/gz'
require 'imw/model/files/bz2'



