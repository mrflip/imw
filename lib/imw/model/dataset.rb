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

    attr_reader :name,:sources,:category

    # Create a dataset of the given +name+ built from the given
    # +sources+ in the given +category+.
    #
    # The name of each dataset must be unique in a collection of
    # datasets.  Each source specified must be the unique name of a
    # source.  If no sources are specified then this dataset's name is
    # used as the name of the source as well.  If no category is
    # specified then the default category +uncategorized+ is used.
    def initialize(name,sources=nil,category=nil)

      @name = name

      if sources then
        @sources = sources.map {|source| Source.new(source)}
      else
        @sources = [Source.new(@name)]
      end

      @category = (category.nil? ? ['uncategorized'] : category)
    end
  end
end

# puts "#{File.basename(__FILE__)}: You lean on your Monkeywrench as you watch the seeds you've planted blossom into beautiful banana trees." # at bottom
