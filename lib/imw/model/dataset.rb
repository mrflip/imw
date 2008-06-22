#
# h2. lib/imw/model/dataset.rb -- class to describe a dataset
#
# == About
#
# Datasets are built by IMW from data sources and this class models
# such datasets.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/paths'

module IMW
  class Dataset

    include IMW::Paths

    attr_reader :name,:sources, :category


    # this whole initialize method needs to be rewritten with
    # validation and with checking against the set of datasets present
    # locally in the fileystem somehow
    def initialize name,sources=nil

      @name = name

      if sources then
        @sources = sources.map {|source| Source.new(source)}
      else
        @sources = [Source.new(@name)]
      end

      @category = ['category','subcat','subsubcat']
    end
  end
end

# puts "#{File.basename(__FILE__)}: You lean on your Monkeywrench as you watch the seeds you've planted blossom into beautiful banana trees." # at bottom
