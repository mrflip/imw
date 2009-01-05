#
# lib/imw/workflow.rb -- implements the workflow class
#
# == About
#
# This file implements the <tt>IMW::Workflow</tt> class which tailors
# the functionality of Rake for IMW objects.
#
# Author::    Philip flip Kromer for infochimps.org (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'rake'
require 'ostruct'

require 'imw/utils'

module IMW

  # <tt>IMW::Workflow</tt> is a class for managing the collection of
  # interdependent tasks involved in processing a dataset.  It uses
  # <tt>Rake</tt> (the <tt>Rake::TaskManager</tt> class, specifically)
  # to handle dependency management.
  class Workflow

    include Rake::TaskManager

    # The steps in the IMW workflow, in order from first to last.
    #   <tt>:rip</tt>:: Data is collected from some source and
    #   deposited in the <tt>:ripd</tt> directory named by the URI for
    #   that source.
    #   
    #   <tt>:peel</tt>:: Data is uncompressed and extracted (if
    #   necessary) from source(s') <tt>:ripd</tt> directory(ies) and
    #   unprocessed files are placed in this dataset's <tt>:rawd</tt>
    #   directory.
    #
    #   <tt>:munge</tt>:: Data is transformed.
    #
    #   <tt>:fix</tt>:: Global quantities (i.e. - averages) are
    #   calculated and records are reconciled.
    #
    #   <tt>:package</tt>:: Data is packaged and compressed (if
    #   necessary) into a delivery format.
    #
    # I think better names might be <tt>:harvest</tt>, <tt>:peel</tt>,
    # <tt>:chew</tt>, <tt>:digest</tt>, and <tt>:shit_out</tt>.  Well,
    # maybe we should stick to <tt>:package</tt>, but still...
    STEPS = [:rip, :peel, :munge, :fix, :package]

    # Hash to convert between the name of a workflow step and the
    # directory which stores data for that step.  Not every step in
    # the workflow has a corresponding data directory.
    STEP_ROOTS = {
      :rip => :ripd_root,
      :peel => :peeld_root,
      :fix => :fixd_root,
      :package =>:pkgd_root
    }

    attr_reader :options

    # Default options passed to <tt>Rake</tt>.  Any class including
    # the <tt>Rake::TaskManager</tt> module must define a constant by
    # this name.
    DEFAULT_OPTIONS = {
      :dry_run => false,
      :trace => false,
      :verbose => false
    }

    def initialize
      super
      # The <tt>Rake::TaskManager</tt> class requires an including class
      # <tt>Example</tt> to define an <tt>OpenStruct</tt> object
      # <tt>Example.options</tt> which individual <tt>Rake::Task</tt>'s
      # check before performing their actions.
      @options = OpenStruct.new(DEFAULT_OPTIONS)
      set_default_tasks
    end

    # Sets the default tasks for this workflow.
    #
    # The  of actions that depend upon
    # one another in a consecutive way (see
    # <tt>IMW::Workflow::STEPS</tt>).  Each task is a
    # <tt>Rake::Task</tt> which depends on the one before it.
    # 
    # Each task does nothing by default other than create directories
    # to hold files for this dataset as it undergoes the workflow.
    def set_default_tasks
      define_task(Rake::Task, {:rip => []})
      define_task(Rake::Task, {:peel => :rip})
      define_task(Rake::Task, {:munge => :peel})
      define_task(Rake::Task, {:fix => :munge})
      define_task(Rake::Task, {:package => :fix})

      comment_default_tasks

    end

    # Set the initial comments for each of the default tasks.
    def comment_default_tasks
      self[:rip].comment = "Obtain a dataset from an origin"
      self[:peel].comment = "Extract a dataset and prepare it for processing."
      self[:munge].comment = "Munge dataset's records into desired form"
      self[:fix].comment = "Reconcile records in a dataset"
      self[:package].comment = "Package dataset into a final format"
    end
    
  end
end


# puts "#{File.basename(__FILE__)}: You find your flow next to a tall tree.  Ahhhh."
