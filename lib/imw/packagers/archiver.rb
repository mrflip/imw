module IMW
  module Packagers
    
    # Packages an Array of input files into a single output archive.
    # When the archive is extracted, all the input files given will be
    # in a single directory with a chosen name.  The path to the output
    # archive determines both the name of the archive and its type (tar,
    # tar.bz2, zip, &c.).
    # 
    # If any of the input files are themselves archives, they will first
    # be extracted, with only their contents winding up in the final
    # directory (the file hierarchy of the archive will be preserved).
    # If any of the input files are compressed, they will first be
    # uncompressed before being added to the directory.
    #
    # Input files can be renamed by passing in a Hash instead of an
    # Array.  Each key in this hash is the path to an input file and its
    # value is the new basename to give it.  If the basename is +nil+
    # then the original path's basename will be used.
    class Archiver

      attr_accessor :name, :inputs

      def initialize name, inputs
        @name   = name
        add_inputs inputs
      end

      #Create a hash structure where every (key,value) pair
      #is a file path and corresponding file basename
      def add_inputs new_inputs
        @inputs ||= {}
        new_inputs.each do |input, basename|
          @inputs[File.expand_path(input)] = (basename || File.basename(input))
        end
      end
      
      def errors
        @errors ||= []      
      end

      def add_processing_error error
        IMW.logger.warn error      
        errors << error
      end

      def success?
        errors.empty?
      end

      # A temporary directory to work in.  Its contents will
      # ultimately consist of a directory named for the package
      # containing all the input files.
      def tmp_dir
        @tmp_dir ||= File.join(IMW.path_to(:tmp_root, 'packager'), (Time.now.to_i.to_s + "-" + $$.to_s)) # guaranteed unique on a node
      end

      def clean!
        FileUtils.rm_rf(tmp_dir)
      end

      # A directory which will contain all the content being packaged,
      # including the contents of any archives that were included in
      # the list of files to process.
      def dir
        @dir ||= File.join(tmp_dir, name.to_s)
      end

      # FIXME This needs to be made idempotent -- calling prepare
      # twice should not do any work the second time (unless the user
      # is insistent and passes a :force option -- or maybe use bang
      # and not-bang versions of the method for this distinction).
      def prepare!
        FileUtils.mkdir_p dir unless File.exist?(dir)
        inputs.each_pair do |path, basename|
          new_path = File.join(dir, basename)
          file = IMW.open(path, :as => IMW::Files.file_class_for(basename)) # file's original path is meaningless: RackMultipart20091203-958-1nkgc61-0
          case
          when file.archive?
            FileUtils.cd(dir) do
              file.extract
            end
          when file.compressed?
            file.cp(new_path).decompress!
          else
            file.cp(new_path)
          end
        end
      end

      #Checks to see if a temporary local directory structure containing
      #the appropriate files has been created.
      def prepared?
        #check if the directory exists right here
        if File.exist?(dir)
          FileUtils.cd(dir)
          inputs.each_pair do |path, basename|
            local_path = File.join(dir, basename)
            #if file exists plainly in local directory, move on to next file
            unless File.exist?(local_path)
              #file does not exist as is, so instantiate a local dummy file and do some checks
              file = IMW.open(local_path, :as => IMW::Files.file_class_for(basename))
              if File.exist?(file.decompressed_path)
                if File.archive?
                  #check that archive contents exist locally
                  list_of_names = file.contents
                  FileUtils.cd(file.decompressed_path) do
                    list_of_names.each do |filename|
                      unless File.exist?(filename)
                        return false
                      end
                    end  
                  end
                  #archive contents check out ok
                end
                #if the file exists in a decompressed way but was not
                #an archive then, move on to next file
              else
                #file does not exist either plainly or in a decompressed form
                return false
              end
            end
          end
          #everything checks out
          return true
        else
          #the directory does not exist locally
          return false
        end
      end
       
      # Package the contents of the temporary directory to an archive
      # at +output+ but return exceptions instead of raising them.
      def package output, options={}
        begin
          package! output, options={}
        rescue RuntimeError => e
          return e
        end
      end

      # Package the contents of the temporary directory to an archive
      # at +output+.
      def package! output, options={}
        output = IMW.open(output)         if output.is_a?(String)
        FileUtils.mkdir_p(output.dirname) unless File.exist?(output.dirname)        
        output.rm!                        if output.exist?
        FileUtils.cd(tmp_dir) do
          temp_output = IMW.open(output.basename)
          puts "MOther FUCKER MY CLASS IS #{temp_output.class}"
          packaged_output = temp_output.create(*Dir["#{name}/**/*"]).mv(output.path)
          temp_output.rm if temp_output.exist?
          add_processing_error "Archiver: couldn't create archive #{output.path}" unless output.exists?
        end
        output
      end
    end
  end
end
