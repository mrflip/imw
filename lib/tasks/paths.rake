#
# h2. imw/tasks/paths -- ensure the standard directory tree exists.
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/workflow/imw_paths'

namespace :pool do
  desc "Construct directory hierarchy"
  task :paths => 'paths:all'

  namespace :paths do
    #
    # Pool Directories
    #
    [:code, :ripd_root, :rawd, :fixd, :pkgd].each do |d|
      directory     $imw.path_to(d)
      # desc "Constructs the :#{d} as #{$imw.path_to(d)}"
      task d => $imw.path_to(d)
      task :all => d
    end

    # Temporary space for /dump
    # desc "Create a symbolic link dump/ pointing to a dumping ground in tmp/"
    task :dump => [$imw.path_to(:dump_root), :dump_file]
    file $imw.path_to(:dump_root) do |t|
      mkdir_p $imw.path_to('/tmp/imw/dump', :csp)
      ln_s    $imw.path_to('/tmp/imw/dump'), $imw.path_to(:dump_root) # unless File.exists?($imw.path_to(:dump_root))
    end
    task :dump_file => $imw.path_to(:dump)
    file $imw.path_to(:dump) do |t|
      mkdir_p $imw.path_to(:dump)
    end
      
    task :all => :dump

    # done
    # puts "#{File.basename(__FILE__)}: Your monkeywrench clears a path through the underbrush."
    
  end
end
