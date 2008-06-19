#
# h2. lib/imw/model/datasource.rb -- class to describe a data source
#
# == About
#
# Data comes into IMW from a data source and this "Data" class models
# such a source.
#
# It wraps the functions used to rip and extract data so that they are
# customized for a particular data source.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/paths'

module IMW

  class DataSource

    include IMW::Paths

    attr_reader :name, :source

    # this initialize method needs to be rewritten with validation
    # etc.
    def initialize name
      @name = name
      @source = "http://www.fakedatasource.com/that/needs/to/be/fixed"
    end

  end

end
# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
