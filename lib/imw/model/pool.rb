#
# h2. lib/imw/model/pool.rb -- describes collections of data sources and datasets
#
# == About
#
# All the datasets and data sources at this IMW installation are
# collectively referred to as the "pool".  Names of data sources or
# datasets should be unique in the pool.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'singleton'

require 'imw/model/source'
require 'imw/model/dataset'

module IMW

  class Pool

    include Singleton

    attr_reader :sources, :datasets

    # Add an <tt>IMW::Source</tt> object +source+ to the pool.
    def add_source source
      source = IMW::Source(source) unless source.is_a? IMW::Source
      raise IMW::Error.new("#{source.name} does not meet the minimum standards to enter the pool") unless source.meets_minimum_standard?
      @sources.append source
    end

    # Add an <tt>IMW::Dataset</tt> object +dataset+ to the pool.
    def add_dataset dataset
      raise IMW::ArgumentError.new("not a valid dataset") unless dataset.is_a? IMW::Dataset
      @datasets.append dataset
    end
    

  end
end

# puts "#{File.basename(__FILE__)}: You dip your Monkeywrench into the whirling maelstrom of Charybdis and pull out...a carton of tube socks! " # at bottom
