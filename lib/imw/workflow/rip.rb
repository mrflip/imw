#
# h2. imw/rip.rb -- Handles ripping data in various ways from the web.
#
# == Accessing Data
# 
# This module will access data online in a variety of formats
#
# * syndicated news feeds (RSS)
# * web pages and files by following following hyperlinks 
#   and/or recursively downloading web directories
#
# and using a variety of protocalls (HTTP, FTP, SFTP, etc.).
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



puts "#{File.basename(__FILE__)}: Dark branches crack like thunder at dusk as your Infinite Monkeywrench rips through the dense undergrowth." # at bottom
