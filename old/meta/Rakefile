#
# h2. Rakefile -- main imw tasks
#
# 
#
# == About
#
# Author::    Philip flip Kromer for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

$VERBOSE = false
verbose(true)

require 'rake'
require 'rake/clean'
require 'imw'
# rake_require 'imw/task

desc "Fiddlefucking"
task :fiddle do
  #   IMWConfig::Config['migrate'] = true
  db_connection=IMWConfig::Config['schemadb']
  db_connection['database'] ||= File.join($IMW_ROOT, db_connection['database_file'])
  ActiveRecord::Base.establish_connection(db_connection)
  require 'imw/model/schemadb_schema'
  require 'imw/model'
  require 'imw/view'
  
  # process_config = YAML.load(File.open($imw.path_to(:pool_config_file)))
  schema = YAML.load(File.open($imw.path_to(:pool_schema_file)))
  schema['infochimps_schema'].each do |pool|
    pool=pool['pool']
    oldpool = Pool.find_by_uniqname(pool['uniqname']) || Pool.new()
    oldpool = oldpool.undump(pool)
    # puts oldpool.to_yaml
    oldpool.save!
    oldpool.datasets.each{ |d| p d ; d.save!}
  end
    
end

#
# Main tasks.  See lib/imw/tasks/*.rake for definitions
#
desc "Acquire data from remote sources"
task :rip

desc "Simple file manipulations"
task :prep   => [:rip]

desc "Data Munging (transformation and extraction)"
task :munge  => [:rip]

desc "Package data into distributable compressed archives."
task :pkg    => [:prep, :munge]

desc "Load data into repository"
task :load   => [:prep, :munge, :pkg]

#desc 'Default: Usage.'
#task :default 

