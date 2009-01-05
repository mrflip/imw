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
  # Each dataset also has a given a taxonomic classification (or
  # taxon, which defaults to the value of
  # <tt>IMW::Dataset::DEFAULT_TAXON</tt>) which determines where files
  # are kept during processing.
  #
  # Each dataset also has a +workflow+ which leverages the
  # functionality of Rake[http://rake.rubyforge.org/] to manage tasks
  # associated with the processing of the dataset along with their
  # dependencies.
  class Dataset

    # The default taxon assigned to a dataset.
    DEFAULT_TAXON = ["misc"]

    attr_reader :handle, :workflow, :taxon

    # Create a new dataset with the given +handle+.
    def initialize handle
      @handle = handle.to_sym
      @workflow = IMW::Workflow.new
      @taxon = DEFAULT_TAXON
    end

    # If the +taxon+ given is a sequence then it is directly
    # interpreted as a taxon.
    #
    # If it is a string, then an attempt is made to interpret it as a
    # pathname of a file within the <tt>IMW::PATHS[:scripts_root]</tt>
    # directory from which the taxon can be determined.  This makes it
    # simple to declare the taxon from a file by passing in the
    # +__FILE__+ variable.  If the string does not represent such a
    # path, then it itself is taken as the taxon.
    def taxon= thing
      if thing.is_a? String then
        if thing.include?(IMW.path_to(:scripts_root)) then
          scripts_dir_length = IMW.path_to(:scripts_root).length
          @taxon = File.dirname(thing).slice(scripts_dir_length,thing.length - scripts_dir_length).split("/")
        else
          @taxon = [thing]
        end
      else
        @taxon = thing
      end
    end

    # If +place+ is one of the steps in
    # <tt>IMW::Workflow::STEP_ROOTS</tt> then return the directory
    # corresponding to this dataset's files, as determined by the step
    # and this dataset's taxon, otherwise just return whatever
    # <tt>IMW.path_to</tt> would return.
    def path_to place
      if IMW::Workflow::STEP_ROOTS.key?(place) then
        IMW.path_to IMW::Workflow::STEP_ROOTS[place], @taxon
      else
        IMW.path_to place
      end
    end

  end
end

# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
