#
# h2. imw/tasks/main.rake -- main workflow actions
#
# pool::    Define and manage data pools
# rip::     Acquire source data
# prep::    Simple file tree preparation
# munge::   Transform source into payload
# pkg::     Package transformed data into loadable/distributable bundle
# load::    Load a packaged dataset into a your datastore
#
# == About
#
# Author::    Philip flip Kromer for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

task :default do |t|
  puts "run 'imw -D' for tasks"
end


# done
# puts "#{File.basename(__FILE__)}: Your monkeywrench grows a large fluffy main of hair."

