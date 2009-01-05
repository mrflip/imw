#
# h2. lib/imw/workflow/scaffold.rb -- scaffold the directory structure for a dataset
#
# == About
#
# Defines workflow tasks for datasets to create directories and
# symlinks to ease the processing of a dataset.
#
# Right now this file contains code written by Flip as well as code
# written by Dhruv which accomplish basically the same task.  Dhruv's
# code integrates with <tt>IMW::Dataset</tt> and Rake and should be
# used preferentially.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: POST NO BILLS.  Is that funny to anyone but me?  No?" # at bottom

require 'rake'
require 'fileutils'

require 'imw/utils'

include FileUtils

module IMW

  ################################################################
  ## FLIP'S CODE
  ################################################################

  def scaffold_script_dirs
    mkdir_p path_to(:me)
  end

  #
  # * creates a directory for the dataset in each of the top-level hierarchies
  #   (as given in ~/.imwrc)
  # * links to that directory within the working directory
  #   in directory pool/foo/bar/baz we'd find
  #     rawd => /data/rawd/foo/bar/baz
  #
  def scaffold_dset_dirs
    [:rawd, :temp, :fixd, :log].each do |seg|
      unless File.exist?(path_to(seg))
        seg_dir = path_to(pathseg_root(seg), :dset)
        mkdir_p seg_dir
        ln_s    seg_dir, path_to(seg)
      end
    end
  end


  #
  # * creates a symlink within the working directory to the
  #   ripped directory, named after its url
  #
  def scaffold_rip_dir url
    unless File.exist?(path_to(seg))
      ripd_dir = path_to(:ripd_root, url)
      mkdir_p ripd_dir
      ln_s    ripd_dir, path_to(:ripd)
    end
  end

  def scaffold_dset
    scaffold_script_dirs
    scaffold_dset_dirs
  end


  ################################################################
  ## DHRUV's CODE -- uses IMW::Dataset and Rake
  ################################################################
  module Workflow

    # Creates a workflow task <tt>:create_directories</tt> to create
    # the directory structure for this dataset.
    def create_directories_task
      @last_description = "Creates directories for this dataset in the peel through package steps."
      define_task(Rake::Task, {:create_directories => []}) do
        [:peel, :munge, :fix, :package].each do |step|
          puts "I am going to create a path to #{path_to step}"
        end
      end
    end

    # Creates a workflow task <tt>:create_symlinks</tt> to create
    # the directory structure for this dataset.
    def create_symlinks_task
      @last_description = "Creates symlinks pointing from the directory containing scripts for this dataset to the directories for the peel through package steps."
      define_task(Rake::Task, {:create_symlinks => [:create_directories]})
    end

  end
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
#     def set_default_tasks
#       define_task(Rake::Task, {:rip => []})
#       define_task(Rake::Task, {:peel => :rip})
#       define_task(Rake::Task, {:munge => :peel})
#       define_task(Rake::Task, {:fix => :munge})
#       define_task(Rake::Task, {:package => :fix})

#       comment_default_tasks

#     end

    # Set the initial comments for each of the default tasks.
#     def comment_default_tasks
#       self[:rip].comment = "Obtain a dataset from an origin"
#       self[:peel].comment = "Extract a dataset and prepare it for processing."
#       self[:munge].comment = "Munge dataset's records into desired form"
#       self[:fix].comment = "Reconcile records in a dataset"
#       self[:package].comment = "Package dataset into a final format"
#     end
    

