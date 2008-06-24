#
# h2. lib/imw/rip.rb -- obtaining data
#
# == About
# 
# This file is just a container for the various methods of obtaining
# data that live in the lib/imw/rip directory.
#
#
# == Processing Data 
#
# Data ripped from the web will not be processed by this module but
# only downloaded, checked for duplication, and saved (perhaps zipped)
# to the 'ripd' directory reserved for this dataset.
#
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/workflow/rip/disk'
require 'imw/workflow/rip/http'

# puts "#{File.basename(__FILE__)}: Dark branches crack like thunder at dusk as your Infinite Monkeywrench rips through the dense undergrowth." # at bottom
