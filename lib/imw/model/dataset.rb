#
# h2. lib/imw/model/dataset.rb -- an imw dataset
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'rake'

require 'imw/utils'
require 'imw/workflow'

module IMW

  # The basic unit in IMW is the dataset.  Each dataset has a
  # +uniqname+ which is meant to be unique (at least in the context of
  # a particular pool of datasets, see <tt>IMW::Pool</tt>).
  #
  # Each dataset also has an +origin+.  If the +origin+ of a dataset
  # is a +String+ (such as <tt>"local_disk"</tt> or
  # <tt>edu.myuniversity</tt>) then it refers to where the data
  # actually came from.  
  #
  # If it is a +Symbol+ then it is assumed to refer to another
  # dataset.  It is through this latter construction that datasets can
  # be built from one another.
  #
  # Each dataset also has a +workflow+ which leverages the
  # functionality of Rake[http://rake.rubyforge.org/] to manage tasks
  # associated with the processing of the dataset along with their
  # dependencies.
  class Dataset

    attr_reader :uniqname, :workflow
    attr_accessor :origin

    # Create a new dataset with the given +uniqname+.
    def initialize uniqname
      @uniqname = uniqname.to_sym
      @workflow = IMW::Workflow.new
    end

    # Returns the path the directory corresponding to the workflow
    # +step+ for this source.
    def path_to step
      File.join(IMW::DIRECTORIES[step], @uniqname.to_s)
    end
  end
end

# puts "#{File.basename(__FILE__)}: You use your Monkeywrench to rake deep and straight furrows in the earth for your orchard." # at bottom
