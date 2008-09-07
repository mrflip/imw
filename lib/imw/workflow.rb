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

  # The <tt>IMW::Workflow</tt> object leverages the functionality of
  # the Rake module for IMW.  It mixes in the
  # <tt>Rake::TaskManager</tt> module which allows an including class
  # to manipulate collections of tasks.
  #
  # The <tt>Rake::TaskManager</tt> class requires an including class
  # <tt>Example</tt> to define an <tt>OpenStruct</tt> object
  # <tt>Example.options</tt> which individual <tt>Rake::Task</tt>'s
  # check before performing their actions.
  class Workflow

    include Rake::TaskManager

    # The steps in the IMW workflow, in order from first to last.
    STEPS = [:rip, :parse, :munge, :fix, :package]

    attr_reader :options

    # Default options
    DEFAULT_OPTIONS = {
      :dry_run => false,
      :trace => false,
      :verbose => false
    }

    def initialize
      super
      @options = OpenStruct.new(DEFAULT_OPTIONS)
      set_default_tasks
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
    
  end
end


# puts "#{File.basename(__FILE__)}: You find your flow next to a tall tree.  Ahhhh."
