#
# h2. lib/imw/workflow/task.rb -- 
#
# == About
#
# This file defines a class <tt>IMW::Task</tt> which subclasses
# <tt>Rake::Task</tt>.  Tasks defined in IMW should be instances of
# <tt>IMW::Task</tt>.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

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



