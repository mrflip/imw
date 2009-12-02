module IMW
  
  # Packages a collection of input files into a single output archive.
  # When the archive is extracted, all the input files given will be
  # in a single directory with a configurable name.  The path to the
  # output archive determines both the name of the archive and its
  # type (tar, tar.bz2, tar.gz, zip).
  # 
  # If any of the input files are themselves archives, they will first
  # be extracted, with only their contents winding up in the final
  # directory (the file hierarchy of the archive will be preserved).
  # If any of the input files are compressed, they will be first be
  # uncompressed before being added to the directory.
  class Packager

    attr_accessor :name, :input_paths

    def initialize name, *input_paths
      @name   = name
      add_input_paths *input_paths
    end

    def add_input_paths *paths
      @input_paths ||= []
      paths.each do |path|
        @input_paths << File.expand_path(path)
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

    def delete_tmp_dir!
      FileUtils.rm_rf(tmp_dir)
    end

    # A directory which will contain all the content being packaged,
    # including the contents of any archives that were included in
    # the list of files to process.
    def archive_dir
      @archive_dir ||= File.join(tmp_dir, name.to_s)
    end

    def collect_contents_in_archive_dir!
      FileUtils.mkdir_p archive_dir unless File.exist?(archive_dir)
      input_paths.each do |path|
        file = IMW.open(path)
        case
        when file.archive?
          FileUtils.cd(archive_dir) do
            file.extract
          end
        when file.compressed?
          file.decompress.mv_to_dir(archive_dir) # FIXME should copy first then decompress...
        else
          file.cp_to_dir(archive_dir)
        end
      end
    end
    
    # Package the contents of the temporary directory to an archive
    # at +output+.
    def package_archive_dir! output, options={}
      output = IMW.open(output)         if output.is_a?(String)
      FileUtils.mkdir_p(output.dirname) unless File.exist?(output.dirname)        
      output.rm!                        if output.exist?
      FileUtils.cd(tmp_dir) do
        temp_output = IMW.open(output.basename)
        packaged_output = temp_output.create(name.to_s + '/*').mv(output.path)
        temp_output.rm if temp_output.exist?
        add_processing_error "Packager: couldn't create package #{output.path}" unless output.exists?
        packaged_output if success?
      end
    end

    def package! output
      output = IMW.open(output) if output.is_a?(String)
      collect_contents_in_archive_dir!
      package_archive_dir! output
      delete_tmp_dir!
      add_processing_error "Packager: couldn't create package #{output.path}" unless output.exists?
      output if success?
    end
  end
end
