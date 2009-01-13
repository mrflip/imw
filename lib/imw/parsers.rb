#
# h2. lib/imw/parsers.rb -- loads parsers
#
# == About
#
# A require farm for the various IMW parsers.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom


require 'imw/parsers/html_parser'
require 'imw/parsers/line_parser'
require 'imw/parsers/flat_file_parser'
