require 'rake'

module IMW

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



