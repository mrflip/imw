#
# h2. lib/imw.rb -- main imw file
#
# == About
#
# This file is the entry-point to the IMW library.  It loads a minimal
# setup.  Optional components can be loaded by calling the function
# <tt>IMW::imw_components</tt>.
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
require 'imw/components'

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

