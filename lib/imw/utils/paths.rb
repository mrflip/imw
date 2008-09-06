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
  def path_to *pathsegs
    path = Pathname.new path_to_helper(*pathsegs)
    path.absolute? ? File.expand_path(path) : path
  end


  # +path_to_helper+ handles the recursive calls for +path_to+.
  private def path_to_helper *pathsegs
    # recursively expand
    expanded = pathsegs.flatten.compact.map do |pathseg|
      pathseg.is_a?(Symbol) ? path_to(paths[pathseg]) : pathseg
    end
    begin joined = File.join(*expanded) rescue raise("Can't find path to '#{pathsegs}' from #{joined.inspect}"); end
    joined
  end
  public
  
  #
  # Adds a symbolic path for expansion by path_to
  #
  def add_path sym, *pathsegs
    @@paths[sym] = pathsegs.flatten
  end
  def paths() @@paths  end


  #
  # Makes a set of symbolic paths referenced to this dataset's path
  #
  def as_dset_paths dset_path, cut_dirs
    if dset_path.is_a?(String)
      require 'pathname'
      dset_path = Pathname.new(dset_path).realpath.to_s
      dset_path = dset_path.chomp('/').split('/')[-(cut_dirs+2)..-cut_dirs]
    end
    add_path :dset, dset_path
    add_path :me,   [:scripts_root, :dset]
    [:rawd, :temp, :fixd, :log, :ripd].each do |seg|
      add_path seg, [:me, seg.to_s]
    end
  end

  def as_dset dset_path, opts={}
    opts = { :cut_dirs => 2, :scaffold => false }.merge opts
    as_dset_paths dset_path, opts[:cut_dirs]
    if opts[:scaffold]
      require 'imw/workflow/scaffold'
      scaffold_dset
    end
  end

  #
  # Canonical log file
  #
  # a file in your
  #
  def log_file_name *args
    log_head = @@paths.include?(:log) ? :log : [:log_root, 'meta']
    log_name = [args, path_datecode].flatten.join('-') + '.log'
    log_path = path_to(log_head, log_name)
    # user can add paths, so re-take the dirname
    mkdir_p File.dirname(log_path)
    log_path
  end


  def path_datecode
    Time.now.strftime("%Y%m%d")
  end

protected

  #
  #   :fixd # => :fixd_root
  def pathseg_root pathseg
    (pathseg.to_s + '_root').to_sym
  end

end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take."
