require 'rake'

module IMW

  # A shallow subclass of the Rake::Task class, used for IMW's
  # workflow's (see IMW::Workflow).
  class Task < Rake::Task
  end

  class Dataset
    include Rake::TaskManager

    # Return a new (or existing) <tt>IMW::Task</tt> with the given
    # +name+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    def task name, &block
      self.define_task IMW::Task, name, &block
    end

  end
end



