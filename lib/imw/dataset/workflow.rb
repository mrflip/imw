require 'imw/dataset/task'
require 'ostruct'

module IMW

  # IMW encourages you to view a data transformation as a network of
  # dependencies.  By default, IMW defines five main steps:
  #
  # rip::
  #   Obtain data via HTTP, FTP, SCP, RSYNC, database query, &c.
  #
  # extract::
  #   Extract data from its ripped form to a form which can be
  #   parsed.
  #
  # parse::
  #   Parse data into a structured form.
  #
  # munge::
  #   Combine, filter, reconcile, and transform already structured
  #   data into a desired form.
  #
  # package::
  #   Archive, compress, and deliver data in its final form to some
  #   location (HTTP, FTP, SCP, RSYNC, S3, EBS, &c.).
  #
  # Each step depends upon the one before it.  The steps are blank by
  # default so there's no need to write code for steps you don't need
  # to use.
  #
  # Each step corresponds to a named directory in IMW::Workflow::DIRS.
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

    # The standard IMW workflow steps.
    STEPS = [:rip,  :extract, :parse, :munge, :package]

    # The steps of the IMW workflow each correspond to a directory in
    # which it is customary that they deposit their files <em>once
    # they are finished processing</em> (so ripped files wind up in
    # the +ripd+ directory, packaged files in the +pkgd+ directory,
    # and so on).
    DIRS  = [:ripd, :xtrd,    :prsd,  :mungd, :pkgd   ]

    # Each workflow step can be configured to take default actions,
    # each action being a proc in the array for the step in this hash.
    #
    # This allows classes which include IMW::Workflow to use class
    # methods named after each step (+rip+, +parse+, &c.) to directly
    # define tasks.
    STEPS_PROCS = returning({}) do |steps_procs|
      STEPS.each do |step|
        steps_procs[step] = []
      end
    end

    protected
    def self.included klass
      STEPS.each do |step|
        klass.class_eval "def self.#{step}(&block); STEPS_PROCS[:#{step}] << block ; end"
      end
    end

    def define_workflow_task deps, comment
      @last_description = comment
      define_task(IMW::Task, deps)
      step = deps.keys.first
      STEPS_PROCS[step].each do |block|
        self[step].enhance do
          self.instance_eval(&block)
        end
      end
    end

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

    # Creates a task <tt>:create_directories</tt> to create the
    # directory structure for this dataset.
    def define_create_directories_task
      @last_description = "Creates workflow directories for this dataset."
      define_task(IMW::Task, {:create_directories => []}) do
        DIRS.each do |dir|
          FileUtils.mkdir_p(path_to(dir)) unless File.exist?(path_to(dir))
        end
      end
    end

    # Creates a task <tt>:destroy</tt> which removes dataset's
    # workflow directories.
    def define_destroy_task
      @last_description = "Get rid of all traces of this dataset."
      define_task(IMW::Task, :destroy => [:create_directories]) do
        DIRS.each do |dir|
          FileUtils.rm_rf(path_to(dir))
        end
      end
    end

    # Creates the task dependency chain <tt>:package => :munge =>
    # :parse => :extract => :rip => :initialize</tt> of the
    # IMW::Workflow.
    def define_workflow_tasks
      define_workflow_task({:rip     => [:create_directories]}, "Obtain data from some source."           )
      define_workflow_task({:extract => [:rip]},                "Extract data so it's ready to parse."    )
      define_workflow_task({:parse   => [:extract]},            "Parse data into a structured form."      )
      define_workflow_task({:munge   => [:parse]},              "Munge structured data into desired form.")
      define_workflow_task({:package => [:munge]},              "Package dataset in final form."          )
    end

  end
end
