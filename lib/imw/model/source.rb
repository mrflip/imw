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
require 'imw/workflow'


module IMW

  class Source

    include IMW::Workflow::Rip

    attr_reader :name, :source

    # this initialize method needs to be rewritten with validation
    # etc.
    def initialize name
      @name = name
    end

    # Returns the path the directory corresponding to the workflow
    # +step+ for this source.
    def path_to step
      raise ArgumentError("The only valid workflow steps for Sources are `:ripd', `:xtrd', or `:dump'.") if not [:ripd,:xtrd,:dump].include? step
      if step == :ripd or step == :xtrd then [IMW::Paths.root_of(step),@source,@name].join('/') else IMW::Paths.root_of(step) end
    end

  end

end
# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
