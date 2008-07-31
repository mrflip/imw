#
# h2. lib/imw/model/source.rb -- class to describe a data source
#
# == About
#
# Data comes into IMW from a data source and this class models such a
# source.
#
# It wraps the functions used to rip and extract data so that they are
# customized for a particular data source.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow'

module IMW

  class Source
    attr_reader :name,:source

    private
    def initialize name, source = nil
      @name = name
      @source = source if source # needs to be removed in favor of reading it from a configuration file.
    end

    public
    # Does this source meet the minimum standards set for an IMW data
    # source?
    def meets_minimum_standard?
      true
    end

    # Returns the path the directory corresponding to the workflow
    # +step+ for this source.
    def path_to step
      valid_steps = IMW::Workflow::SOURCE_STEPS + [:dump]
      raise IMW::ArgumentError.new("invalid workflow step `#{step}', try #{valid_steps.quote_items 'or'}") unless valid_steps.include? step
      File.join(IMW::DIRECTORIES[step], @source, @name)
    end
  end

end

# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
