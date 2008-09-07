#
# h2. lib/imw/utils.rb -- utility functions
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require 'rubygems'
require 'imw'
require 'imw/utils/error'
require 'imw/utils/announce'
require 'imw/utils/config'
require 'imw/utils/paths'
require 'imw/utils/misc'
require 'imw/utils/extensions/core'
# some stupid collision with datamapper makes it double include
require 'YAML' unless defined?('YAML')


# puts "#{File.basename(__FILE__)}: Early economists thought they would measure the utility of an action in units of `utils'.  Really." # at bottom

module IMW
  # parent
end
