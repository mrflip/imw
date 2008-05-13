#
# h2. imw/tasks/prep --  Simple file tree preparation
#
#
# prep:copy     copy files (with renaming) (prep_config_[coll].yaml)
# prep:repack   open specified packages; copy with rename; kill temp.
#               unpackage. (prep_config_[coll].yaml)
# prep:chunk    break a file up at a byte marker, at a line number, or
#               at the nearest following regexp match.
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
require 'imw'

# #
# #
# desc <<-EOF
# Process the raw files and canonicalize and structure the payload (constructs
# the rawd/ tree from the ripd/ tree) The output files are exactly and only
# what the downloader receives.
# EOF
# task :prep => 'prep:all'
# 
# namespace :prep do
#   desc "fixd/ files"
#   task :files => [$imw.path_to(:fixd)] do |t|
#   end
#   task :all => :files
#   
#   desc "fixd/ schema"
#   task :schema => [$imw.path_to(:fixd), :files] do |t|
#   end
#   task :all => :schema
# end

#
# RAWS
#
# desc "Acquire the raw files (constructs the rawd/ tree from the ripd/ tree)"
# task :rawd => [:process, $imw.path_to(:rawd_root), :ripd] do |t|
#   $imw.log("Running task %s" % [t.name])
# end

# done
# puts "#{File.basename(__FILE__)}: Your monkeywrench pops the collar on its pink Izod shirt"
