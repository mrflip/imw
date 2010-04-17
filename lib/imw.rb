require 'rubygems'
require 'imw/boot'
require 'imw/utils'
require 'imw/dataset'
require 'imw/repository'
require 'imw/files'
require 'imw/parsers'
require 'imw/packagers'

# The Infinite Monkeywrench (IMW) is a Ruby library for ripping,
# extracting, parsing, munging, and packaging datasets.  It allows you
# to handle different data formats transparently as well as organize
# transformations of data as a network of dependencies (a la Make or
# Rake).
#
# On first reading of IMW examine the classes within the IMW::Files
# module, all transparently instantiated when using IMW.open (instead
# of File.open).  These classes do a lot of work to ensure that all
# objects returned by IMW.open share methods (write, read, load, dump,
# parse, compress, extract, &c.) while continuing to use existing
# implementations of these concepts.  
#
# Another entrace point is the <tt>IMW::Dataset</tt> class.  It
# leverages Rake to craft workflows for transforming datasets.  IMW
# encourages you to organize your data transformations in a step-wise
# process, managed with dependencies.
#
# Utilities to help with one step in particular (ripping, parsing,
# pacaking, &c.) are in their own directories.
module IMW
end
