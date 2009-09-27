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

require 'imw/dataset/scaffold'
require 'imw/dataset/task'

module IMW

  # The <tt>IMW::Workflow</tt> module is a collection of methods which
  # define Rake[http://rake.rubyforge.org/] tasks specialized for each
  # dataset.
  module Workflow

    # The functions called here define the default tasks associated
    # with each dataset.
    def create_default_tasks
      create_directories_task
      create_symlinks_task
      create_initialize_task
      create_delete_data_task
      create_destroy_task
      create_workflow_tasks
    end

    # Sets the default tasks in this workflow.
    #
    # The default tasks constitute a set of consecutive actions that
    # must be taken in order: <tt>:rip</tt>, <tt>parse</tt>,
    # <tt>munge</tt>, <tt>fix</tt>, and <tt>package</tt>.  Each task
    # is a <tt>Rake::Task</tt> which depends on the one before it.
    #
    # Each task does nothing by default other than create directories
    # to hold files for this dataset as it undergoes the workflow.
    def set_default_tasks
      define_task(Rake::Task, {:rip => []})
      define_task(Rake::Task, {:parse => :rip})
      define_task(Rake::Task, {:munge => :parse})
      define_task(Rake::Task, {:fix => :munge})
      define_task(Rake::Task, {:package => :fix})
      comment_default_tasks
    end

    # Set the initial comments for each of the default tasks.
    def comment_default_tasks
      self[:rip].comment = "Rip dataset from an origin"
      self[:parse].comment = "Parse dataset into intermediate form"
      self[:munge].comment = "Munge dataset's structure into desired form"
      self[:fix].comment = "Fix and format dataset"
      self[:package].comment = "Package dataset into a final format"
    end

    # Creates the task dependency chain <tt>:package => :fix => :munge
    # => :peel => :rip => :initialize</tt>.
    def create_workflow_tasks
      @last_description = "Obtain data from some source."
      define_task(IMW::Task, :rip     => [:initialize])
      @last_description = "Extract datafiles from ripped data."
      define_task(IMW::Task, :peel    => [:rip])
      @last_description = "Transform records in a dataset."
      define_task(IMW::Task, :munge   => [:peel])
      @last_description = "Reconcile records."
      define_task(IMW::Task, :fix     => [:munge])
      @last_description = "Package dataset in final form."
      define_task(IMW::Task, :package => [:fix])
    end

  end
end

# puts "#{File.basename(__FILE__)}: You find your flow next to a tall tree.  Ahhhh."
