#
# h2. lib/imw/utils/paths.rb -- defines local paths to IMW directories
#
# == About
#
# IMW keeps files for sources and datasets are in many directories on
# the system.  IMW objects come with +path_to+ methods which point at
# relevant directories.
#
# The functions defined here are intended for quick and simple access
# to directories, providing a simple shorthand mechanism for
# identifying and recalling paths, suitable for use in interactive
# sessions or in simple scripts.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

module IMW

  @@paths = {}

  public
  # Returns pathnames from shorthand input in various formats.
  #
  # It does nothing to strings but maintains a hash between symbols
  # and paths (accessible via <tt>IMW.add_path</tt>,
  # <tt>IMW.rm_path</tt>, &c.) so that symbols can be used as
  # shorthand for actual paths.
  #
  # Quick file globbing:
  #
  #   Dir.glob(IMW.path_to(:tmp, 'foo', '*'))
  #
  # Adding a one-off directory for a dataset:
  #
  #   IMW.add_path :mlb_08, 'gd2.mlb.com/components/game/mlb/year_2008'
  #   IMW.path_to :ripd, :mlb_08, 'month_06', 'day_08', 'miniscoreboard.xml'
  #     => (...)/data/ripd/gd2.mlb.com/components/game/mlb/year_2008/month_06/day_08/miniscoreboard.xml
  def self.path_to *dir_specs
    # recursively expand
    expanded = dir_specs.flatten.map do |dir_spec|
      dir_spec.is_a?(Symbol) ? path_to(paths[dir_spec]) : dir_spec
    end
    joined = File.join(*expanded)
    # memoize
    # @@paths[dir_specs[0]] = joined if (dir_specs.length==1 && dir_specs[0].is_a?(Symbol))
    joined
  end

  # Adds the symbolic path +sym+ defined by +dirs+.
  def self.add_path sym, *dirs
    
@@paths[sym] = dirs.flatten





  end

  # Removes the symbolic path +sym+.
  def self.delete_path sym
    @@paths.delete sym
  end
  
  # Return the list of paths.
  def self.paths() @@paths  end

end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take."
