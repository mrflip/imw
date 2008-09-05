#
# h2. lib/imw/model/pool.rb -- describes collections of datasets
#
# == About
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/utils'
require 'imw/utils/extensions/find'

module IMW

  # A collection of datasets is referred to as a "pool" and this is a
  # container class with useful methods for operating on such
  # collections.
  class Pool

    attr_reader :datasets

    include Enumerable
    
    private
    # Initialize this pool with the uniqnames of datsets culled from
    # the files in +paths+.
    #
    # Ex:
    #
    #   IMW::Pool.new "/path/to/dir_of_datasets", "/path/to/a_particular_dataset.instructions.yaml"
    def initialize *paths
      @datasets = paths.flatten.map {|path| File.directory?(path) ? Find.uniqnames_in_directory(path) : File.uniqname(path) }.flatten
    end
        
    public
    # Iterate over the items in this pool.
    def each
      @datasets.each {|dataset| yield dataset}
    end

    # Add a +dataset+ to the pool.
    def add dataset
      @datasets.add(dataset.uniqname)
    end

    # Delete +datset+ from the pool.
    def delete dataset
      @datasets.delete(dataset.uniqname)
    end

    # Return the path to the given workflow +step+ for the given +dataset+.
    def path_to step, dataset
      raise IMW::Error.new("#{dataset.uniqname} not in pool") unless include? dataset.uniqname
      IMW::Dataset.new(dataset.uniqname)
    end
    
  end
  
end

# puts "#{File.basename(__FILE__)}: You dip your Monkeywrench into the whirling maelstrom of Charybdis and pull out...a carton of tube socks! " # at bottom
