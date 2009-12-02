#
# h2. imw/tasks/rip -- Acquire raw data from an external source
#
# rip:urls    store as ripd/com.reversed/url/dirs/files
#
# == About
#
# Author::    Philip flip Kromer for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 


desc "Pull in the raw files from the web (constructs the ripd/ tree)"
task :rip => 'rip:all'

namespace :rip do
  task :all 
end

# done
# puts "#{File.basename(__FILE__)}: Your infinite monkeywrench cuts a hole in the fabric of space and extracts a surprising quantity of stuff from within."
