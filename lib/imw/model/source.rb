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

require 'rake'

require 'imw/utils'
require 'imw/workflow'

module IMW
  
  # Data comes into IMW from various sources and must be processed
  # before it can be assembled into datasets (see
  # <tt>IMW::Dataset</tt>).  The <tt>IMW::Source</tt> class provides
  # an interface for dealing with messy data sources.
  class Source

    attr_reader :uniqname,:origin, :workflow

    # The steps in the workflow in which information is considered to
    # be part of a source.
    WORKFLOW_STEPS = [:ripd, :prsd, :dump]

    private
    # Create a new source with the given +uniqname+ which should be a
    # symbol unique to this source for this IMW installation.
    def initialize uniqname
      @uniqname = uniqname.to_sym
      @workflow = IMW::Workflow.new
    end

    # Path to the IMW configuration file for this Source.
    def config_file_path
      File.join(IMW::DIRECTORIES[:sources],

    public
    # Set the origin of this source.
    def origin= origin
      @origin = origin
      WORKFLOW_STEPS.each {|step| FileUtils.mkdir_p(path_to(step)) unless File.exist?(path_to(step))}
    end

    # Returns the path the directory corresponding to the workflow
    # +step+ for this source.
    def path_to step
      raise IMW::Error.new("This source is of unknown origin and so cannot be assigned a path on the filesystem.") unless @origin
      raise IMW::Error.new("Workflow step (#{step}) must be one of #{WORKFLOW_STEPS.quote_items_with 'or'}") unless WORKFLOW_STEPS.include? step
      File.join(IMW::DIRECTORIES[step], @origin, @uniqname.to_s)
    end
  end
end

# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
