#
# lib/imw/workflow.rb -- describes the whole imw workflow
#
# == About
#
# This file contains constants about the workflow itself that aren't
# specific to any of its steps.
#
# Author::    Philip flip Kromer for infochimps.org (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 


module IMW
  module Workflow

    # The steps in the IMW workflow, in order from first to last.
    STEPS = [:ripd, :xtrd, :prsd, :mungd, :fixd, :pkgd]

    # List of steps in which information is considered part of a "data
    # source" and under the control of an <tt>IMW::Source</tt> object.
    SOURCE_STEPS = [:ripd, :xtrd, :prsd]

    # List of setps in which information is considered part of a
    # "dataset" and under the control of an <tt>IMW::Dataset</tt>
    # object.
    DATASET_STEPS = [:mungd, :fixd, :pkgd]
    
  end
end


# puts "#{File.basename(__FILE__)}: You find your flow next to a tall tree.  Ahhhh."
