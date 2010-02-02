module IMW
  module Files
    #
    # h2. lib/imw/files/file.rb -- base class for files
    #
    # == About
    #
    # Defines a base class for classes for specific filetypes to subclass.
    #
    # Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
    # Copyright:: Copyright (c) 2008 infochimps.org
    # License::   GPL 3.0
    # Website::   http://infinitemonkeywrench.org/
    #
    # puts "#{File.basename(__FILE__)}: At the very bottom of the office building, wedged between a small boulder and a rotting log you see a weathered manilla file folder.  The writing on the tab is too faded to make out." # at bottom
    module BasicFile

      attr_reader :uri, :host, :path, :dirname, :basename, :extname, :name

      protected

      def uri= uri
        @uri      = uri.is_a?(URI::Generic) ? uri : URI.parse(uri)
        @host     = self.uri.host
        @path     = local? ? ::File.expand_path(self.uri.path) : self.uri.path
        @dirname  = ::File.dirname path
        @basename = ::File.basename path
        @extname  = find_extname
        @name     = @basename[0,@basename.length - @extname.length]
      end

      # Some files (like <tt>.tar.gz</tt>) have an "extra" extension.
      # Classes in the <tt>IMW::Files</tt> module should define a
      # class method <tt>extname</tt> which returns the their full
      # extension.
      def find_extname
        self.class.respond_to?(:extname) ? self.class.extname(path) : ::File.extname(path)
      end

      public

      # Is this file on the local machine (the scheme of the file's URI is nil or
      def local?
        host == 'file' || host.nil?
      end

      # Is this file on a remote machine?
      def remote?
        (! local?)
      end

      # Steal a bunch of class methods from File which only take a
      # path as a first argument.
      [:executable?, :executable_real?, :file?, :directory?, :ftype, :owned?, :pipe?, :readable?, :readable_real?, :setgid?, :setuid?, :size, :size?, :socket?, :split, :stat, :sticky?, :writable?, :writable_real?, :zero?].each do |class_method|
        define_method class_method do
          File.send(class_method, path)
        end
      end

      # Is there a real file at the path of this File?  Will attempt
      # to open files online too to check.
      def exist?
        if local?
          ::File.exist?(path)
        else
          begin
            true if open(uri)
          rescue SocketError
            false
          end
        end
      end
      alias_method :exists?, :exist?

      # Delete this file.
      def rm
        raise IMW::PathError.new("cannot delete remote file #{uri}")     unless local?
        raise IMW::PathError.new("cannot delete #{uri}, doesn't exist!") unless exist?
        FileUtils.rm path
      end
      alias_method :rm!, :rm

      # Copy this file to +new_path+.
      def cp new_path
        raise IMW::PathError.new("cannot copy from #{path}, doesn't exist!") unless exist?
        if local?
          FileUtils.cp path, new_path
        else
          # FIXME better way to do this?
          File.open(new_path,'w') { |f| f.write(open(uri).read) }
        end
        self.class.new(new_path)
      end

      # Copy this file to +dir+.
      def cp_to_dir dir
        cp File.join(File.expand_path(dir),basename)
      end

      # Move this file to +new_path+.
      def mv new_path
        raise IMW::PathError.new("cannot move from #{path}, doesn't exist!") unless exist?
        if local?
          FileUtils.mv path, new_path
        else
          # FIXME better way to do this?
          File.open(new_path,'w') { |f| f.write(open(uri).read) }
        end
        self.class.new(new_path)
      end
      alias_method :mv!, :mv

      # Move this file to +dir+.
      def mv_to_dir dir
        mv File.join(File.expand_path(dir),basename)
      end
      alias_method :mv_to_dir!, :mv_to_dir
    end
  end
end


