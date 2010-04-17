#
# Infinite Monkeywrench -- Main tasks
#
#
# h2. imw/tasks/pool -- manage and create data pools
#
# pool:generate::   creates a new munger project config.yaml, munge.rake                
# pool:rename::     dest=newcat/newsubcat/newpool
# pool:metrics::    
#   * for each of [:ripd, :rawd, :pool, :fixd]:
#     * # files, directories, directory depth
#     * total size in bytes
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
require      'imw'

namespace :pool do
  
  # make the dirs be there
  desc "Generate a new datapool"
  task :generate => [:paths, 'generate:all']
  namespace :generate do

    desc "Place skeleton files into the pool's code directory"
    task :skel => [:paths] 
    etc_skeletons = {
      :pool_config => "imw_config_template.yaml"     ,
      :pool_munger => "imw_munger_template.rb"       ,
      :pool_schema => "imw_schema_template.icss.yaml",
    }
    etc_skeletons.each do |destfile, skelfile|
      file $imw.path_to(destfile) do |t|
        cp $imw.path_to(:imw_etc, 'skel', skelfile), $imw.path_to(destfile)         
      end
      task :skel => $imw.path_to(destfile)
    end
    task :all => :skel
    
    # desc "make symbolic links to other segments"
    task :links => [:paths]  do
      [[:ripd_root,'ripd'], [:rawd,'rawd'], [:dump,'dump'], [:fixd,'fixd']].each do |d,l|
        link = $imw.path_to(:code, l.to_s)
        ln_s $imw.path_to(d), link unless File.exist?(link)
      end
      
    end
    task :all => :links

  end
  
  # file collection_schema do
  #   #
  #   # Insert a collection
  #   collection_template_file        = imw.path_to(:code_bin, 'template_template.icss.yaml.erb')
  #   collection_template_erb         = Erubis::Eruby.new(File.read(collection_template_file))
  #   File.open(collection_schema, 'wb') do |f|
  #     f << collection_template_erb.result(binding())
  #   end 
  # 
  # end

  
end
# puts "#{File.basename(__FILE__)}: There is no P in this pool. As far as you know." 
