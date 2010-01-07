require 'imw/dataset/task'
require 'ostruct'

module IMW

  # The <tt>IMW::Workflow</tt> module is a collection of methods which
  # leverage Rake[http://rake.rubyforge.org/] to implement a
  # dependency chain of processing required by a particular dataset.
  module Workflow

    # The <tt>Rake::TaskManager</tt> module allows the
    # <tt>IMW::Dataset</tt> class to leverage the functionality of the
    # Rake[http://rake.rubyforge.org/] library to manage tasks
    # associated with the processing of this dataset.
    include Rake::TaskManager

    # Default options passed to <tt>Rake</tt>.  Any class including
    # the <tt>Rake::TaskManager</tt> module must define a constant by
    # this name.
    DEFAULT_OPTIONS = {
      :dry_run => false,
      :trace   => false,
      :verbose => false
    }

    # The IMW workflow is composed of five standard steps:
    #
    # rip::
    #   Obtain data from somewhere.
    #
    # extract::
    #   Extract data from its ripped form to a form which can be
    #   parsed.
    #
    # parse::
    #   Parse data into a structured form.
    #
    # munge::
    #   Transform structured data into the desired form.  <em>This is
    #   where the magic happens!</em>
    #
    # package::
    #   Archive, compress, and deliver data in its final form.
    #
    # Each step depends upon the last but IMW doesn't force you to
    # write any code that isn't necessary.
    #
    # Each step corresponds to a named directory in IMW::Workflow::DIRS
    STEPS = [:rip,  :extract, :parse, :munge, :package]

    # The steps of the IMW workflow each correspond to a directory in
    # which it is customary that they deposit their files <em>once
    # they are finished processing</em> (so ripped files wind up in
    # the +ripd+ directory, packaged files in the +pkgd+ directory,
    # and so on.
    DIRS  = [:ripd, :xtrd,    :prsd,  :mungd, :pkgd   ]

    protected
    # Create all the instance variables required by Rake::TaskManager
    # and define default tasks for this dataset.
    def initialize_workflow
      @tasks = Hash.new
      @rules = Array.new
      @scope = Array.new
      @last_description = nil
      @options = OpenStruct.new(DEFAULT_OPTIONS)
      define_create_directories_task
      define_workflow_tasks      
      define_destroy_task
    end

    # Creates a workflow task <tt>:create_directories</tt> to create
    # the directory structure for this dataset.
    def define_create_directories_task
      @last_description = "Creates workflow directories for this dataset."
      define_task(IMW::Task, {:create_directories => []}) do
        DIRS.each do |dir|
          FileUtils.mkdir_p(path_to(dir)) unless File.exist?(path_to(dir))
        end
      end
    end

    # Creates a task <tt>:destroy</tt> which does nothing but depends
    # upon all the tasks required to delete the dataset's data and
    # remove its footprint from IMW.
    def define_destroy_task
      @last_description = "Get rid of all traces of this dataset."
      define_task(IMW::Task, :destroy => [:create_directories]) do
        DIRS.each do |dir|
          FileUtils.rm_rf(path_to(dir))
        end
      end
    end

    # Creates the task dependency chain <tt>:package => :munge =>
    # :parse => :extract => :rip => :initialize</tt>.
    def define_workflow_tasks
      @last_description = "Obtain data from some source."
      define_task(IMW::Task, :rip     => [:create_directories])
      
      @last_description = "Extract data so it's ready to parse."
      define_task(IMW::Task, :extract    => [:rip])
      
      @last_description = "Parse data into a structured form."
      define_task(IMW::Task, :parse   => [:extract])
      
      @last_description = "Munge structured data into desired form."
      define_task(IMW::Task, :munge     => [:parse])
      
      @last_description = "Package dataset in final form."
      define_task(IMW::Task, :package => [:munge])
    end
    
  end
end
