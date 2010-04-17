require 'find'

module CustomMatchers
  # Match the contents of an object against files or directories
  # in +paths+.
  #
  # Options include:
  # 
  # <tt>:relative_to</tt>:: a leading path which will be stripped
  # from all +paths+ before comparison with the contents of the
  # directory.
  class PathsMatcher

    attr_accessor :relative_to, :paths, :obj

    private
    def initialize paths,opts = {}
      opts.reverse_merge!({:relative_to => nil})
      paths = [paths] if paths.class == String
      @paths = paths
      @relative_to = opts[:relative_to]
      find_paths_contents
    end

    def find_paths_contents
      # find all the files
      contents = []
      paths.each do |path|
        path = File.expand_path path
        if File.file? path then
          contents << path
        elsif File.directory? path then
          directory_paths = []
          Find.find(path) { |p| directory_paths << p if File.file?(p) }
          contents += directory_paths
        end
      end

      # strip leading path
      if relative_to
        contents.map! do |path|
          # the +1 is because we want a relative path
          path = path[relative_to.length + 1,path.size]
        end
      end

      @paths_contents = contents.to_set
    end

    def pretty_print set
      set.to_a.join("\n\t")
    end
    
    public
    def matches? obj
      @obj = obj
      @obj_contents = obj.contents.to_set
      @obj_contents == @paths_contents
    end

    def failure_message
      missing_from_obj   = "missing from obj:\n\t#{pretty_print(@paths_contents - @obj_contents)}\n"
      missing_from_paths = "missing from paths:\n\t#{pretty_print(@obj_contents - @paths_contents)}\n"
      common = "common to both:\n\t#{pretty_print(@obj_contents & @paths_contents)}\n"
      "expected contents of obj (#{obj.path}) and paths (#{paths.join(", ")}) to be identical.\n#{missing_from_obj}\n#{missing_from_paths}\n#{common}"
    end

    def negative_failure_message
      "expected contents of obj (#{obj.path}) and paths (#{paths.join(", ")}) to differ."
    end
    
  end

  def contain_paths_like paths, opts = {}
    PathsMatcher.new(paths,opts)
  end
  
end
