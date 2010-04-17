#
# h2. imw/tasks/pkg --  Infinite Monkeywrench Packaging tasks
#
# pkg             copies appropriate files and takes any active_munger output
# pkg:dump        dump active_record data into [yaml, csv, json, xml]
#                 or one-by-one => pkg:dump:yaml, :csv, :json, :xml
# pkg:tar_bz2     also :zip -- take the
# 
# pkg:killfixd    
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw'

#
# Main pkg task
#
desc "Generate distributable packages"
task :pkg => 'pkg:all'

# Please prepare, munge and dump files first
task 'pkg:prereqs' => [:munge, :prep, :dump]
# Also, give us that landing place  
task 'pkg:prereqs' => $imw.path_to(:pkgd)

namespace :pkg do  
  #
  # Compressed bundle
  #
  require 'rake/packagetask'
  pkg_formats = IMWConfig::Config['pkg_formats']
  commands = { 'tar.bz2' => 'tar',  'tar.gz' => 'tar',  'zip' => 'zip' }
  flags    = { 'tar.bz2' => 'jcvf', 'tar.gz' => 'zcvf', 'zip' => '-r' }
  pkg_formats.each do |pkg_format|
    pkg_name = $imw.path_to(:pkgd, $imw.pool + '.' + pkg_format)
    src_dir  = $imw.path_to(:fixd_root, :cat, :subcat)
    src_name = $imw.pool
    file pkg_name do 
      sh %{cd #{src_dir}; #{commands[pkg_format]} #{flags[pkg_format]} #{pkg_name} #{src_name} }
    end
    task pkg_format => [:prereqs, pkg_name]
    task :package => pkg_format
  end
  task :all => :package
  
  desc "Force a rebuild of the package files"
  task :repackage => [:clobber, :package]
  
  desc "Remove package products" 
  task :clobber do
    rm_r Dir[$imw.path_to(:pkgd, '*')] rescue nil
  end

end # :pkg namespace

# done
# puts "#{File.basename(__FILE__)}: Wielding a wrench this mighty accentuates your package.  The one you're carrying."
