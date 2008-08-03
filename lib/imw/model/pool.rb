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

require 'imw/utils'
require 'imw/utils/extensions/find'

module IMW

  # A collection of data sources or datasets is referred to as a
  # "pool" and this is a container class with useful methods for
  # operating on such collections.  See also <tt>IMW::POOL</tt>.
  class Pool

    attr_reader :sources

    include Enumerable
    
    private
    # Initialize this pool by recursively scanning +dir+ and adding
    # (unique) items based on the filenames found.
    def initialize dir
      @items = Find.files_in_directory(dir).map {|path| File.name(path) }.uniq.map {|item| item.to_sym}
    end

    # Return the uniqname of +object+, whatever it is.
    def uniqname_of object
      object.respond_to? :uniqname ? object.uniqname : object.to_sym
    end

    public
    # Iterate over the items in this pool.
    def each
      @items.each {|item| yield item}
    end

    # Add an item to the pool.
    def add item
      item = uniqname_of(item)
      raise IMW::Error.new("#{item} already included") if include? item
      @items << item
    end

    # Delete a +source+ from the pool.
    def delete item
      @items.delete(uniqname_of(item))
    end
  end
  
end

# puts "#{File.basename(__FILE__)}: You dip your Monkeywrench into the whirling maelstrom of Charybdis and pull out...a carton of tube socks! " # at bottom
