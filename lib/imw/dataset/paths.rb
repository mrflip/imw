module IMW

  class Dataset
    include IMW::Paths

    # A dataset keeps track of its own collection of paths just like
    # IMW itself.  When an IMW::Dataset is instantiated in a script,
    # that script's directory becomes the dataset's +self+ path and
    # the default workflow directories (see IMW::Workflow) are created
    # within this directory.
    #
    # You can change a dataset's paths the same way you can change
    # IMW's paths; calling +add_path+ and +remove_path+ on the
    # dataset.
    #
    # To customize this behavior for all future datasets, created a
    # subclass of IMW::Dataset and override the +set_paths+ method.
    def paths
      @paths
    end
    
    protected
    # Sets the roots of various paths relative to this dataset.
    def set_root_paths
      @paths = {}
      add_path :script, File.expand_path(eval('__FILE__'))      
      add_path :self,   File.dirname(path_to(:script))
      IMW::Workflow::DIRS.each do |dir|
        add_path dir, :self, dir.to_s
      end
    end

    # Overwrite this method to set additional paths for the dataset.
    def set_paths
    end
  end
    
end
