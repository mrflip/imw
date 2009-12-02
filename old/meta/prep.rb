# require "rubygems"
# require "mime/types"

require 'fileutils'

class IMW
  
  # Copies file or files from
  # 
  #   * :srcdir prefix directory in path_to form 
  #   * :destdir destination directory in path_to form
  #   * Options
  #   * * :match => /blarg-(\w+)-(\d{4})\..*/ -- a regex object
  #       only files matching this filter are passed through.
  #   * * :sub   => /egad_(.*)_([^_]*)\.rb/   -- a regex object
  #   * * :repl  => a string with 'zounds_\2-\1' type backreferences
  #                 OR a proc.  The parameters to the &proc  
  #   * * :verbose Trace execution of each function (by default to STDERR,
  #       although this can be overridden by setting the class variable
  #       @fileutils_output).
  #   * * :noop Do not perform the action of the function (useful for testing
  #       scripts).
  #   * * :force Override some default conservative behavior of the method (for
  #       example overwriting an existing file).
  #   * * :preserve Attempt to preserve atime, mtime, and mode information from
  #       src in dest. (Setuid and setgid flags are always cleared.)
  #   * * a block to be called on each filename
  # 
  # The pattern or glob and the substitution are performed against the path
  # __relative__ to the source: and dest: directories respectively. That is, if
  # you specify :srcdir => [:ripd, 'foo.bar.com/path/to'] and :glob =>
  # 'years_*/*.csv' the block will receive strings of the form 'years_*/*.csv',
  # without the prefixed path.
  
  def copy_with_rename(src_dir, src_glob, dest_dir, opts={ }, &block)
    # fill in 
    Dir.chdir(path_to(src_dir)) do # restores original dir on block exit
      Dir.glob(src_glob) do |src_name|
        dest_name = src_name
        # filter by :match regexp
        next unless (!opts[:match] || opts[:match].match(dest_name))
        # Do a regexp substitution to the file
        case 
        when (opts[:sub] && !opts[:repl]) 
          raise ArgumentError.new("Need a :repl option to go with a :sub option.") 
        when (opts[:sub] && opts[:repl].is_a?(Proc))
          dest_name = dest_name.gsub(opts[:sub], &opts[:repl])
        when (opts[:sub])
          dest_name = dest_name.gsub(opts[:sub], opts[:repl])
        end
        # Pass each file to the block
        if block 
          dest_name = yield dest_name
        end
        opts[:verbose] = true ; # opts[:noop] = true; 
        fileutils_opts = opts.slice(:verbose, :noop, :force, :preserve)
        dest_path = path_to(dest_dir, dest_name)
        mkdir_p File.dirname(dest_path), fileutils_opts
        cp(src_name, dest_path, fileutils_opts)
      end        
    end
  end
  
  def copy_dammit
  end
  
  def munge (schema_commands)
    
  end
  
  
  def unpackage(pkg_seg, pkg_filename, target_seg, target_dir)
    filetype = identify(file)    
    self.log "Unpacking %s" % filetype
    
    cmds = { 
      :tar_bz2 => "tar xvjf #{file} --directory=#{dir}", 
      :tar_gz => "tar xvzf  #{file} --directory=#{dir}", 
    }
    sh cmds[filetype]
  end
  
  #
  # Determine filetype
  # 
  # use assoc as it has to be in order (.tar.gz vs .gz)
  attr :filetypes
  @@filetypes = 
    [
    [/\.icss.yaml$/, :icss], 
    [/\.tar\.bz2$/,  :tar_bz2], 
    [/\.tar\.gz$/,   :tar_gz], 
    [/\.tgz$/,       :tar_gz], 
    [/\.flat.txt$/,  :flat],  
  ]+%w{ gz zip yaml csv xml tsv }.map{ |ext| [/\.#{ext}$/, ext.intern] }
  # Return a symbol uniquely identifying that flavor of file
  def filetype(file)
    puts MIME::Types.type_for("echoditto_zip2rep_database.tar.gz")
    @@filetypes.each do |filepair| ; filematcher, filetype = filepair
      return filetype if filematcher.match(file)
    end
    :unknown
  end
  


  # copy file, possibly renaming.  Each arg can be an array (path_to() called on it)
  def copy_and_rename(src_dir, dest_dir, src_dest_hash)
    src_dir  = [src_dir]  if !(src_dir.isa? Array)
    dest_dir = [dest_dir] if !(dest_dir.isa? Array)
    src_dest_hash.each do |src, dest|
      cp( path_to(src_dir+[src]), path_to(dest_dir+[dest]) )
    end
  end
  
end
