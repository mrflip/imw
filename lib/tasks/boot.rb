# Create the IMW object
# FIXME -- this doesn't seem like the right way to do this.
require 'imw'

$imw = IMW.new_from_env()
puts "Working on data pool #{$imw.me}"
