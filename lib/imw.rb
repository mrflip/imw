#
# h2. lib/imw.rb -- main imw file
#
# == About
#
# This file is the entry-point to the IMW library.  It loads a minimal
# setup.  Optional components can be loaded by calling the function
# <tt>IMW.imw_components</tt>.
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
require 'imw/dataset'
require 'imw/files'
require 'imw/parsers'
require 'imw/packagers'

# The Infinite Monkeywrench (IMW) is a Ruby library for obtaining,
# parsing, transforming, reconciling, and packaging datasets.
#
# Data is obtained via FIXME
#
# Data is loaded into IMW using <tt>IMW.open</tt> which provides a
# uniform interface across a variety of data formats.  The objects
# returned will each have +load+ method which will return data in the
# best form for further processing.  If the data is a YAML file, then
# Ruby's +YAML+ library will be used to return primitive Ruby objects,
# if it is a CSV, then the +FasterCSV+ library will be used, &c.
#
# The main interface to handling data is the <tt>IMW::Dataset</tt>
# class.  It has methods for summarizing, transforming, and dumping
# data to a variety of formats.
module IMW
end
