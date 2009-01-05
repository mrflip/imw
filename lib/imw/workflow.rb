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

require 'imw/workflow/scaffold'

module IMW

  # The <tt>IMW::Workflow</tt> module is a collection of methods which
  # define Rake[http://rake.rubyforge.org/] tasks specialized for each
  # dataset.
  module Workflow

    def create_default_tasks
      create_directories_task
      create_symlinks_task
    end
  end
end

# puts "#{File.basename(__FILE__)}: You find your flow next to a tall tree.  Ahhhh."
