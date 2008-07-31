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
      unless IMW::DIRECTORIES.has_key? step
        raise IMW::ArgumentError.new("No such IMW directory, `#{step}'.  Choose from #{IMW::DIRECTORIES.keys.map do |key| '`' + key.to_s + '\'' end.join ', '}")
      end
      IMW::DIRECTORIES[step]
    end
  end

  # expands a shorthand workflow path specification to an
  # actual file path.
  #
  # Ex:
  #
  # Dir[IMW.path_to(:temp, 'foo', '*')]
  #
  # IMW.add_path :mlb_08, 'gd2.mlb.com/components/game/mlb/year_2008'
  # IMW.path_to :ripd, :mlb_08, 'month_06', 'day_08', 'miniscoreboard.xml'
  # => (...)/data/ripd/gd2.mlb.com/components/game/mlb/year_2008/month_06/day_08/miniscoreboard.xml
  #
  def self.path_to *dir_specs
    # recursively expand
    expanded = dir_specs.flatten.map do |dir_spec|
      dir_spec.is_a?(Symbol) ? path_to(paths[dir_spec]) : dir_spec
    end
    joined = File.join(*expanded)
    # memoize
    paths[dir_specs[0]] ||= joined if (dir_specs.length==1 && dir_specs[0].is_a?(Symbol))
    joined
  end

  #
  # Adds a symbolic path for expansion by path_to
  #
  def self.add_path sym, *dirs
    @@paths[sym] = dirs.flatten
  end

end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take."
