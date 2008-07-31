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

require 'imw/model/files/file'
require 'imw/model/source'
require 'imw/model/dataset'
require 'imw/utils'

module IMW

  class Pool

    include Singleton

    attr_reader :sources, :datasets

    private
    def initialize
      find_sources
    end

    # Scan the pool directory and add all sources which meet the
    # minimum standard.
    def find_sources
      contents = Dir.new(IMW::DIRECTORIES[:sources]).abs_contents.map
      names = []
      contents.uniq.each {|thing| names << IMW::Files::File.new(thing).name if File.file? thing }
      sources = []
      names.uniq.each do |name|
        source = IMW::Source.new(name)
        sources << source if source.meets_minimum_standard?
      end
      @sources = sources
    end

    public
    # Add an <tt>IMW::Source</tt> object +source+ to the pool.
    def add_source source
      source = IMW::Source(source) unless source.is_a? IMW::Source
      raise IMW::Error.new("#{source.name} does not meet the minimum standards to enter the pool") unless source.meets_minimum_standard?
      @sources.append source
    end

    # Check whether +source+ is in the pool.
    def has_source? source
      source = source.name if source.respond_to? :name
      @sources.map {|s| s.name}.include? source
     end

  end
end

# puts "#{File.basename(__FILE__)}: You dip your Monkeywrench into the whirling maelstrom of Charybdis and pull out...a carton of tube socks! " # at bottom
