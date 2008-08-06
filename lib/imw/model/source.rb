#
# h2. lib/imw/model/source.rb -- class to describe a data source
#
# == About
#
# The <tt>IMW::Source</tt> class.
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

  # Data comes into IMW from various sources and must be pre-processed
  # before it can be assembled into datasets (see
  # <tt>IMW::Dataset</tt>).  The <tt>IMW::Source</tt> class provides
  # an interface for dealing with messy data sources.
  class Source

    # The default source for an <tt>IMW::Source</tt> object if no
    # other source is specified.
    DEFAULT_SOURCE = "unknown"
    
    attr_reader :uniqname,:source

    private
    # Create a new source with the given +uniqname+ which should be a
    # symbol unique to this source for this IMW installation.
    def initialize uniqname
      @uniqname = uniqname.to_sym
      @source = DEFAULT_SOURCE
    end

    public
    # Returns the path the directory corresponding to the workflow
    # +step+ for this source.
    def path_to step
      valid_steps = IMW::Workflow::SOURCE_STEPS + [:dump]
      raise IMW::ArgumentError.new("invalid workflow step `#{step}', try #{valid_steps.quote_items_with 'or'}") unless valid_steps.include? step
      File.join(IMW::DIRECTORIES[step], @source, @uniqname.to_s)
    end
  end

end

# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
