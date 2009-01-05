#
# h2. lib/imw/workflow/task.rb -- defines IMW Rake task
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
end



