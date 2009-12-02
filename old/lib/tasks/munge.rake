#
# h2. imw/tasks/munge -- Extract and Transform data
#
# munge:go          run the munge() routine?  Something.    
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

# namespace :munge do
# 
#   desc "fixd/ files"
#   task :files => [imw.path_to(:fixd_coll)] do |t|
#     imw.log("Running task %s" % [t.name])
#   end
#   desc "fixd/ schema"
#   task :schema => [imw.path_to(:fixd_coll), :files] do |t|
#     imw.log("Running task %s" % [t.name])
#   end
#   
#   task :tell => [] do |t|
#     schds = YAML.load(File.open(imw.path_to(:code_me, :schema_datasets)))
#     puts schds.to_yaml
#   end
#   
# end

# puts "#{File.basename(__FILE__)}: Using your monkeywrench variously as a cudgel, lever, c-clamp and occasionally a wrench, you quickly line everything up for processing" # at bottom
