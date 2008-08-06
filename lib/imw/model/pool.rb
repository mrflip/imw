#
# h2. lib/imw/model/pool.rb -- describes collections of data sources and datasets
#
# == About
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'set'

require 'imw/utils'
require 'imw/utils/extensions/find'

module IMW

  # A collection of data sources or datasets is referred to as a
  # "pool" and this is a container class with useful methods for
  # operating on such collections.
  class Pool

    attr_reader :items, :klass

    include Enumerable
    
    private
    # Initialize this pool with uniqnames from the files in +paths+
    # with the understanding that this is a pool of items of class
    # +klass+.
    #
    # Ex:
    #
    #   sources = IMW::Pool.new IMW::Source, "/path/to/dir_of_sources", "/path/to/a_particular_source.yaml"
    def initialize klass, *paths
      @klass = klass
      @items = paths.flatten.map {|path| File.directory?(path) ? Find.uniqnames_in_directory(path) : File.uniqname(path) }.flatten.to_set
    end
        
    public
    # Iterate over the items in this pool.
    def each
      @items.each {|item| yield item}
    end

    # Add an +item+ to the pool.
    def add item
      @items.add(item.uniqname)
    end

    # Delete +item+ from the pool.
    def delete item
      @items.delete(item.uniqname)
    end

    # Return the path to the given workflow +step+ for +item+.
    def path_to step, item
      raise IMW::Error.new("#{item} not in pool") unless include? item.uniqname
      @klass.new(item.uniqname).path_to(step)
    end
    
  end
  
end

# puts "#{File.basename(__FILE__)}: You dip your Monkeywrench into the whirling maelstrom of Charybdis and pull out...a carton of tube socks! " # at bottom
