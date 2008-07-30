#
# h2. lib/imw/utils/paths.rb -- defines local paths to IMW directories
#
# == About
#
# IMW uses lots of different directories to keep information on data
# and datasets separate.  This module interfaces with the
# configuration files to establish the paths to these IMW directories
# and provides functions and mixins for IMW objects to use to access
# these paths.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils'

module IMW

  module Paths

    # Returns the root of workflow `step'
    def self.root_of(step)
      raise IMW::ArgumentError.new("No such IMW directory, `#{step}'.  Choose from #{IMW::DIRECTORIES.keys.map do |key| '`' + key.to_s + '\'' end.join ', '}") unless IMW::DIRECTORIES.has_key? step
      IMW::DIRECTORIES[step]
    end

  end

end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take." 
