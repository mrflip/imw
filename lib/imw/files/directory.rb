require 'imw/files/basicfile'
module IMW
  module Files
    class Directory

      include IMW::Files::BasicFile

      # FIXME these should be defined by BasicFile and then removed here but I don't see how...
      # [:executable?, :executable_real?, :pipe?, :socket?, :rm, :rm!, :extname, :extname=, :name, :name=].each do |method|
      #   instance_eval do
      #     remove_method method
      #   end
      # end

      def uri= uri
        @uri      = uri.is_a?(URI::Generic) ? uri : URI.parse(uri)
        @host     = self.uri.host
        @path     = local? ? ::File.expand_path(self.uri.path) : self.uri.path
        @dirname  = ::File.dirname path
        @basename = ::File.basename path
      end

      def initialize uri
        self.uri = uri
      end

      def [] selector='*'
        Dir[File.join(path, selector)] if local?
      end
      def contents
        []
      end
      
      
      # Copy the contents of this directory to +new_dir+.
      def cp new_dir
        raise IMW::PathError.new("cannot copy from #{path}, doesn't exist!") unless exist?
        if local?
          FileUtils.cp_r path, new_dir
        else
          raise IMW::PathError.new("cannot recursively copy remote directories (yet!)")
        end
        self.class.new(new_dir)
      end

      # Move this directory to +new_dir+.
      def mv new_dir
        raise IMW::PathError.new("cannot move from #{path}, doesn't exist!") unless exist?
        if local?
          FileUtils.mv path, new_dir
        else
          raise IMW::PathError.new("cannot move remote directories (yet!)") 
        end
        self.class.new(new_dir)
      end
      alias_method :mv!, :mv

      # Move this directory so it sits beneath +dir+.
      def mv_to_dir dir
        mv File.join(File.expand_path(dir),basename)
      end
      alias_method :mv_to_dir!, :mv_to_dir

    end
  end
end
