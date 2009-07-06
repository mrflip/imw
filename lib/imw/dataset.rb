#
# h2. lib/imw/dataset.rb -- imw dataset
#
# == About
#
# Defines basic properties of the <tt>IMW::Dataset</tt>
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom

require 'rake'
require 'ostruct'

require 'imw/utils'
require 'imw/workflow'
require 'imw/dataset/loaddump'
require 'imw/dataset/stats'

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
  # Each dataset is also capable of managing a collection of tasks
  # using the Ruby Rake[http://rake.rubyforge.org/] library.
  class Dataset

    # The <tt>Rake::TaskManager</tt> module allows the
    # <tt>IMW::Dataset</tt> class to leverage the functionality of the
    # Rake[http://rake.rubyforge.org/] library to manage tasks
    # associated with the processing of this dataset.
    include Rake::TaskManager

    # The <tt>IMW::Workflow</tt> module contains pre-defined tasks for
    # dataset processing.
    include IMW::Workflow

    attr_reader :handle, :taxon, :options
    attr_accessor :data

    # The default taxon assigned to a dataset.
    DEFAULT_TAXON = ["misc"]

    # The steps in the IMW workflow, in order from first to last.
    # 
    #   <tt>:rip</tt>:: Data is collected from some source and
    #   deposited in the <tt>:ripd</tt> directory named by the URI for
    #   that source.
    #   
    #   <tt>:peel</tt>:: Data is uncompressed and extracted (if
    #   necessary) from source(s') <tt>:ripd</tt> directory(ies) and
    #   unprocessed files are placed in this dataset's <tt>:peeld</tt>
    #   directory.
    #
    #   <tt>:munge</tt>:: Data is read from the <tt>:peeld</tt>
    #   directory, transformed, and placed into the <tt>:mungd</tt>
    #   directory.
    #
    #   <tt>:fix</tt>:: Global quantities (i.e. - averages) are
    #   calculated and records are reconciled and written to the
    #   <tt>:fixd</tt> directory.
    #
    #   <tt>:package</tt>:: Data is packaged and compressed (if
    #   necessary) into a delivery format and deposited into the
    #   <tt>:pkgd</tt> directory</tt>.
    #
    # I think better names might be <tt>:harvest</tt>, <tt>:peel</tt>,
    # <tt>:chew</tt>, <tt>:digest</tt>, and <tt>:shit_out</tt>.  Well,
    # maybe we should stick to <tt>:package</tt>, but still...
    WORKFLOW_STEPS = [:rip, :peel, :munge, :fix, :package]

    # Hash to convert between the name of a workflow step and the
    # corresponding directory.
    WORKFLOW_STEP_DIRS = {
      :rip     => :ripd,      
      :peel    => :peeld,
      :munge   => :mungd,
      :fix     => :fixd,
      :package => :pkgd
    }

    # Hash to convert between the name of a workflow step and the name
    # of the root of the directory stores data for that step.
    WORKFLOW_STEP_ROOTS = {
      :rip     => :ripd_root,      
      :peel    => :peeld_root,
      :munge   => :mungd_root,
      :fix     => :fixd_root,
      :package => :pkgd_root
    }
    
    # Default options passed to <tt>Rake</tt>.  Any class including
    # the <tt>Rake::TaskManager</tt> module must define a constant by
    # this name.
    DEFAULT_OPTIONS = {
      :dry_run => false,
      :trace => false,
      :verbose => false
    }

    # Create a new dataset.  Arguments include
    #
    #   <tt>:taxon</tt> (+DEFAULT_TAXON+):: a string or sequence
    #   giving the taxonomic classification of the dataset.  See
    #   <tt>IMW::Dataset.taxon=</tt> for more details on how this
    #   argument is interpreted.
    def initialize handle, options = {}
      defaults = {
        :taxon => DEFAULT_TAXON
      }
      options.reverse_merge! defaults

      # FIXME is this how the attribute writer functions should be
      # called?
      self.handle= handle
      self.taxon= options[:taxon]

      # for rake
      @tasks = Hash.new
      @rules = Array.new
      @scope = Array.new
      @last_description = nil
      @options = OpenStruct.new(DEFAULT_OPTIONS)
      create_default_tasks
    end

    def handle= thing
      @handle = thing.is_a?(String) ? thing.to_handle : thing
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

    # If +place+ is one of the steps in +WORKFLOW_STEP_ROOTS+ then
    # return the directory corresponding to this dataset's files, as
    # determined by the step and this dataset's taxon.
    #
    # If +place+ is <tt>:script</tt> then return the directory
    # corresponding to this dataset's script's.
    #
    # Otherwise just return whatever <tt>IMW.path_to</tt> would
    # return.
    def path_to place
      if WORKFLOW_STEP_ROOTS.key?(place) then
        IMW.path_to(WORKFLOW_STEP_ROOTS[place], @taxon, @handle.to_s)
      elsif place == :script then
        IMW.path_to(:scripts_root, @taxon, @handle.to_s)
      else
        IMW.path_to(place)
      end
    end
  end
end
