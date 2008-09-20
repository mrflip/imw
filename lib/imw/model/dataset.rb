#
# h2. lib/imw/model/dataset.rb -- an imw dataset
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/utils'
require 'imw/workflow'

module IMW

  # The basic unit in IMW is the dataset.  Each dataset has a
  # +handle+ which is meant to be unique (at least in the context of
  # a particular pool of datasets, see <tt>IMW::Pool</tt>).
  #
  # Each dataset also has an +origin+.  If the +origin+ of a dataset
  # is a +String+ (such as <tt>"local_disk"</tt> or
  # <tt>edu.myuniversity</tt>) then it refers to where the data
  # actually came from.
  #
  # If it is a +Symbol+ then it is assumed to refer to another
  # dataset.  It is through this latter construction that datasets can
  # be built from one another.
  #
  # Each dataset also has a +workflow+ which leverages the
  # functionality of Rake[http://rake.rubyforge.org/] to manage tasks
  # associated with the processing of the dataset along with their
  # dependencies.
  class Dataset

    attr_reader :handle, :workflow
    attr_accessor :origin

    # Locations where this dataset keeps its instructions, logging
    # output, or temporary files, respectively.
    PLACES = [:instructions,:log,:dump]

    # Create a new dataset with the given +handle+.
    def initialize handle
      @handle = handle.to_sym
      @workflow = IMW::Workflow.new
      create_directory_structure
    end

    # Returns the path to the directory corresponding to +place+.
    # +place+ can be a step in the workflow (see
    # <tt>IMW::Workflow::STEPS</tt>) or a specific place (see
    # <tt>IMW::Dataset::PLACES</tt>).
    def path_to place
      if IMW::Workflow::STEPS.include?(place) then
        File.join(IMW::DIRECTORIES[place], @handle.to_s)
      elsif PLACES.include?(place) then
        File.join(IMW::DIRECTORIES[place],@handle.to_s)
      else
        raise IMW::PathError.new("There is no directory for this dataset corresponding to `#{place}'.")
      end
    end

    # Create workflow tasks to create the basic directory structure
    # for this dataset.
    #
    # Note: no directories will actually be created until the workflow
    # for this dataset is invoked.
    def create_directory_structure
      IMW::Workflow::STEPS.each do |step|
        @workflow[step].enhance do
          FileUtils.mkdir_p(path_to(step)) unless File.exist?(path_to(step))
          FileUtils.ln_s(path_to(step),File.join(path_to(:instructions),step.to_s)) unless File.exist?(File.join(path_to(:instructions),step.to_s))
        end
      end
    end

  end
end

# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
