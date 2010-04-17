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
  def paths() IMW::PATHS  end


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
    [:rawd, :tmp, :fixd, :log, :ripd].each do |seg|
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
    log_head = IMW::PATHS.include?(:log) ? :log : [:log_root, 'meta']
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

  # Removes a symbolic path for expansion by +path_to+.
  def self.remove_path sym
    IMW::PATHS.delete sym if IMW::PATHS.include? sym
  end
end

# puts "#{File.basename(__FILE__)}: Your monkeywrench glows alternately dim then bright as you wander, suggesting to you which paths to take."
