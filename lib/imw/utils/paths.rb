#
# h2. lib/imw/utils/paths.rb -- defines the path structure of IMW
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

module IMW

  # Implements methods designed to work with an object's
  # <tt>@paths</tt> attributes, adding and deleting symbolic
  # references to paths and expanding calls to +path_to+ from that
  # attribute or (when a miss) from <tt>IMW::PATHS</tt>.
  #
  # An including class should therefore define an array attribute
  # <tt>@paths</tt>.
  module Paths

    # Expands a shorthand workflow path specification to an
    # actual file path.
    #
    #   add_path :mlb_08, 'gd2.mlb.com/components/game/mlb/year_2008'
    #   path_to :ripd, :mlb_08, 'month_06', 'day_08', 'miniscoreboard.xml'
    #   => (...)/data/ripd/gd2.mlb.com/components/game/mlb/year_2008/month_06/day_08/miniscoreboard.xml
    def path_to *pathsegs
      begin
        path = Pathname.new path_to_helper(*pathsegs)
        path.absolute? ? File.expand_path(path) : path.to_s
      rescue Exception => e
        raise("Can't find path to '#{pathsegs}': #{e}");
      end
    end

    private
    def path_to_helper *pathsegs # :nodoc:
      # +path_to_helper+ handles the recursive calls for +path_to+.
      expanded = pathsegs.flatten.compact.map do |pathseg|
        case
        when pathseg.is_a?(Symbol) && @paths.include?(pathseg)     then path_to(@paths[pathseg])
        when pathseg.is_a?(Symbol) && IMW::PATHS.include?(pathseg) then path_to(IMW::PATHS[pathseg])          
        when pathseg.is_a?(Symbol)                                 then raise IMW::PathError.new("No path expansion set for #{pathseg.inspect}")
        else pathseg
        end
      end
      File.join(*expanded)
    end
    public

    # Adds a symbolic path for expansion by +path_to+.
    def add_path sym, *pathsegs
      @paths[sym] = pathsegs.flatten
    end

    # Removes a symbolic path for expansion by +path_to+.
    def remove_path sym
      @paths.delete sym if @paths.include? sym
    end
  end

  class Dataset
    attr_reader :paths
    include IMW::Paths

    private
    def set_paths
      @paths = {}
      add_path :self, File.dirname(eval('__FILE__'))
    end
  end
    
  def self.path_to *pathsegs
    begin
      path = Pathname.new IMW.path_to_helper(*pathsegs)
      path.absolute? ? File.expand_path(path) : path.to_s
    rescue Exception => e
      raise("Can't find path to '#{pathsegs}': #{e}");
    end
  end

  private
  def self.path_to_helper *pathsegs # :nodoc:
    # +path_to_helper+ handles the recursive calls for +path_to+.
    expanded = pathsegs.flatten.compact.map do |pathseg|
      case
      when pathseg.is_a?(Symbol) && IMW::PATHS.include?(pathseg) then path_to(IMW::PATHS[pathseg])          
      when pathseg.is_a?(Symbol)                                 then raise IMW::PathError.new("No path expansion set for #{pathseg.inspect}")
      else pathseg
      end
    end
    File.join(*expanded)
  end
  public

  # Adds a symbolic path for expansion by +path_to+.
  def self.add_path sym, *pathsegs
    IMW::PATHS[sym] = pathsegs.flatten
  end

  # Removes a symbolic path for expansion by +path_to+.
  def self.remove_path sym
    IMW::PATHS.delete sym if IMW::PATHS.include? sym
  end
end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take."
