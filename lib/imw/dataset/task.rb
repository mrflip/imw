require 'rake'

module IMW

  Task             = Class.new(Rake::Task)
  FileTask         = Class.new(Rake::FileTask)
  FileCreationTask = Class.new(Rake::FileCreationTask)  

  class Dataset
    include Rake::TaskManager

    # Return a new (or existing) <tt>IMW::Task</tt> with the given
    # +name+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    def task name, &block
      self.define_task IMW::Task, name, &block
    end

    # Return a new (or existing) <tt>IMW::FileTask</tt> with the given
    # +name+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    def file name, &block
      self.define_task IMW::FileTask, name, &block
    end

    # Return a new (or existing) <tt>IMW::FileCreationTask</tt> with the given
    # +name+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    def file_create name, &block
      self.define_task IMW::FileCreationTask, name, &block
    end

    # Override this method to define default tasks for a subclass of
    # IMW::Dataset.
    def set_tasks
    end
  end
end



