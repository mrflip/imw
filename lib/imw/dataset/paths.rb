module IMW

  class Dataset
    attr_reader :paths
    include IMW::Paths

    protected
    def set_paths
      @paths = {}
      self_path = File.dirname(eval('__FILE__'))
      puts "THE PATH TO THIS DATASET IS #{self_path} because __FILE__ = #{eval('__FILE__')}"
      add_path :self, self_path
      IMW::Workflow::DIRS.each do |dir|
        add_path dir, :self, dir.to_s
      end
    end
  end
    
end
