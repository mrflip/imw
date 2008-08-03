#
# h2. lib/imw/utils/boot.rb -- startup functions
#
# == About
#
# This file contains code necessary to boot the Infinite Monkeywrench
# at a particular site.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'fileutils'

require 'imw/utils'
require 'imw/model/pool'
require 'imw/utils/paths'

module IMW

  # A pool for all the sources at this IMW installation.
  IMW::SOURCES = IMW::Pool.new(IMW::DIRECTORIES[:sources])

  # Initialize IMW.paths to hold various useful paths at startup.
  IMW::DIRECTORIES.each_pair {|name,path| IMW.add_path name, path }
  
end

# puts "#{File.basename(__FILE__)}: You heft up your Infinite Monkeywrench for the first time and marvel at how something so powerful could be made so wondrous light!" # at bottom
