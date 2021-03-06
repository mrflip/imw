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
    class Archiver

      attr_accessor :name, :inputs

      def initialize name, inputs
        @name   = name
        @inputs = inputs.map { |input| File.expand_path(input) }
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

      # Copy, decompress, or extract the input paths to the temporary
      # directory, readying them for pacakging.
      def prepare!
        FileUtils.mkdir_p dir unless File.exist?(dir)
        inputs.each do |path|
          existing_file = IMW.open(path)          
          new_path      = File.join(dir, File.basename(path))
          case
          when existing_file.archive?
            FileUtils.cd(dir) do
              existing_file.extract
            end
          when existing_file.compressed?
            existing_file.cp(new_path).decompress!
          else
            existing_file.cp(new_path)
          end
        end
      end        
      
      # Checks to see if all expected files exist in the temporary
      # directory for this packager.
      def prepared?
        inputs.each do |path|
          existing_file = IMW.open(path)
          new_path      = File.join(dir, File.basename(path))
          case
          when existing_file.archive?
            existing_file.contents.each do |archived_file_path|
              return false unless File.exist?(File.join(dir, archived_file_path))
            end
          when existing_file.compressed?
            return false unless File.exist?(IMW.open(new_path).decompressed_path)
          else
            return false unless File.exist?(new_path)
          end
        end
        true
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
        prepare!                          unless prepared?
        output = IMW.open(output)         if output.is_a?(String)
        FileUtils.mkdir_p(output.dirname) unless File.exist?(output.dirname)        
        output.rm!                        if output.exist?
        FileUtils.cd(tmp_dir) do
          temp_output = IMW.open(output.basename)
          packaged_output = temp_output.create(*Dir["#{name}/**/*"]).mv(output.path)
          temp_output.rm if temp_output.exist?
          add_processing_error "Archiver: couldn't create archive #{output.path}" unless output.exists?
        end
        output
      end
    end
  end
end
