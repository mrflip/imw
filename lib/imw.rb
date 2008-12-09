#
# h2. lib/imw.rb -- main imw file
#
# == About
#
# This file is the entry-point to the IMW library.  It starts up by
# loading up all the other required files, including those responsible
# for parsing configuration settings and setting initial constants.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Behold, the weighty, the munificent, the Infinite Monkeywrench! Approach it with care: it has overwhelmed mightier monkeys than ye."

require 'rubygems'
require 'YAML' unless defined?('YAML') # some stupid collision with datamapper makes it double include
require 'imw/boot'
require 'imw/utils'
require 'imw/model'

#
# Gem Dependencies:
#
#   addressable
#   activesupport
#   yaml
#   json
#
#   datamapper
#
#
module IMW
end

