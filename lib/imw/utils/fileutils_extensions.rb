#
# h2. lib/imw/utils/fileutils_extensions.rb -- extensions to the FileUtils module of the Ruby standard library
#
# == About
#
# Yes, the the Ruby FileUtils module is wonderful!  It's brilliant!
# But...I wish I had some "higher level" functions that did more
# complicated tasks.  So here they are!
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'
require 'find'

require 'imw/utils/config'
require 'imw/utils/error'

module FileUtils

  # default options for smart_copy
  SMART_COPY_OPT_DEFAULT = {}

  # Copies +sources+ to +dest+ with _smart_ default behavior.
  #
  # +sources+ can be a string naming a file or directory or an array
  # of such strings.  +dest+ is a directory in which to copy the
  # sources, which will be created if necessary.
  #
  # Files in a single directory will be copied without dragging
  # along the enclosing directory.  A collection of single files
  # will all be copied into the same directory.  Multiple
  # directories or a mixture of directories and files will be
  # copied along with the enclosing directories:
  #
  # <tt>smart_copy("file1","dest")</tt>:: creates <tt>dest/file1</tt>
  # <tt>smart_copy("dir1")</tt>:: creates <tt>dest/[contents of dir1]</tt>
  # <tt>smart_copy(["file1","file2",...])</tt>:: creates <tt>dest/file1, dest/file2,...</tt>
  # <tt>smart_copy(["dir1","dir2",...])</tt>:: creates <tt>dest/dir1/[contents of dir1], dest/dir2/[contents of dir2], ...</tt>
  # <tt>smart_copy(["dir1","file1","file2",...])</tt>:: creates <tt>dest/dir1/[contents of dir1], dest/file1, dest/file2, ...</tt>
  #
  # All path names will be expanded to absolute paths before any
  # actions are taken.
  #
  # An options hash includes the following options (with their default
  # values in parentheses):
  #
  # <tt>:dir_perms</tt> (0755):: permissions to create directories with
  # <tt>:file_perms</tt> (0755):: permissions to create files with
  # <tt>:force</tt> (false):: overwrite existing files and directories when copying (overridden by <tt>:prompt</tt>)
  # <tt>:ignore_empty</tt> (true):: won't copy empty files or directories
  # <tt>:prompt</tt> (false):: prompt when overwriting files or directories (overrides <tt>:force</tt>)
  # <tt>:simulate</tt> (false):: print what will be done without doing it
  # <tt>:symlinks_only</tt> (false):: don't actually copy anything; merely create symlinks
  # <tt>:verbose</tt> (false):: print detailed output
  #
  # Unrecognized options will be passed to <tt>FileUtils.cp</tt> and
  # <tt>FileUtils.cp_r</tt>.
  def self.smart_copy(sources,dest,opts={})

    # deal with options...how i miss python...
    options = {
      :dir_params => 0755,
    }.merge opts

    options[:file_perms] = 0755
    options[:force] = false
    options[:ignore_empty] = true
    options[:prompt] = false
    options[:simulate] = false
    options[:symlinks_only] = false
    options[:verbose] = false
    options.update(opts)

    # options' constraints
    options[:force] = false if options[:prompt]
    options[:verbose] = true if options[:simulate]

    # for uniform code later...
    sources = [sources] if sources.class == String

    # check destination
    dest = File.expand_path(dest)
    # if the destination exists
    if File.exist?(dest) then
      if File.file?(dest) then
        # and is a file then bail
        raise ArgumentError.new("#{dest} exists but is a file, not a directory.")
      elsif File.directory?(dest) then
        # if it's a directory then continue with a warning
        $stderr.puts "directory #{dest} already exists" if options[:verbose]
      end
    else
      # otherwise just create it and roll
      Dir.mkdir(dest,options[:dir_perms]) unless options[:simulate]
      $stdout.puts "created directory #{dest}" if options[:verbose]
    end

    # copy files
    sources.find_all {|source| File.file?(source)}.each do |file|
      
      begin

        # ignore empty files
        if options[:ignore_empty] and File.stat(file).size == 0 then
          $stderr.puts "skipping empty #{file}" if options[:verbose]
          next
        end

        # decide whether to copy file
        new_file = [dest,File.basename(file)].join('/')
        # if file exists
        if File.exist?(new_file) then
          # and it's a file
          if File.file?(new_file) then
            if options[:prompt] then
              # prompt for overwrite if that's an option
              yn = ''
              until IMW::Yeses.member?(yn) || IMW::Nos.member?(yn) do
                $stdout.puts "overwrite file #{new_file}? "
                yn = $stdin.gets.chomp!
              end
              IMW::Yeses.member?(yn) ? write_file = true : write_file = false

            else
              # if not prompting then see if we force overwrite
              options[:force] ? write_file = true : write_file = false
              $stdout.puts "#{new_file} already exists" if options[:verbose]
            end
            
            # bail if it's a directory
          elsif File.directory?(new_file) then raise IMW::Error.new("file #{new_file} is a directory!") end

          # of course if the file doesn't exist then we simply write to it
        else write_file = true end
        
        # copy file
        if write_file then
          if options[:symlinks_only] then
            FileUtils.ln_sf(file,new_file,:verbose => options[:verbose]) unless options[:simulate]
          else
            FileUtils.cp(file,new_file,:verbose => options[:verbose]) unless options[:simulate]
          end
          FileUtils.chmod(options[:file_perms],new_file) unless options[:simulate]
        else
          $stdout.puts "no action taken" if options[:verbose] and not options[:prompt]
        end
        
        # case 
        # when options[:symlinks_only] ...

        # permission denied
      rescue Errno::EACCES
        $stderr.puts "permission denied for #{file}"
        next
        # no such file
      rescue Errno::ENOENT
        $stderr.puts "no such file #{source}"
        next
      end
    end
    
    # recurse into directories
    sources.find_all {|source| File.directory?(source)}.each do |dir|
      begin
        dest_dir = [dest,File.basename(dir)].join('/')
        dir_contents = Dir.entries(dir)
        # make sure to get rid of . and ..
        dir_contents.delete('.')
        dir_contents.delete('..')
        dir_contents = dir_contents.map {|entry| File.expand_path([dir,entry].join('/'))}
        smart_copy(dir_contents,dest_dir,opts)
      rescue Errno::EACCES
        $stderr.puts "permission denied to #{dir}" if options[:verbose]
        next
      end
    end
    
  end

  # Finds all archives in the given directory and extracts them.
  #
  # Supported archive types include <tt>tar</tt>, <tt>bz2</tt>,
  # <tt>gz</tt>, <tt>tar.gz</tt>, <tt>tgz</tt>, <tt>tar.bz2</tt>,
  # <tt>tbz2</tt>, <tt<tt>rar</tt> and <tt>zip</tt>.
  #
  # Options (with their default values in parentheses) include:
  # <tt>:simulate</tt> (false):: Show what would be done without doing it.
  # <tt>:keep_archives</tt> (false):: Keep archives after extracting files from them.
  # <tt>:force</tt> (true):: Rewrite already extracted files.
  # <tt>:verbose</tt> (false):: Print output.
  # <tt>:tar_path</tt> ('tar'):: Path to the tar program.
  # <tt>:bzip2_path</tt> ('bzip2'):: Path to the bzip2 program.
  # <tt>:gzip_path</tt> ('gzip'):: Path to the gzip program.
  # <tt>:unrar_path</tt> ('unrar'):: Path to the unrar program.
  # <tt>:unzip_path</tt> ('unzip'):: Path to the unzip program.
  def self.decompress_directory(directory,user_opts={})

    # set default options and update with user options
    options = {:simulate => false, :keep_archives => false, :verbose => false, :tar_path => 'tar', :bzip2_path => 'bzip2', :gzip_path => 'gzip', :unrar_path => 'unrar', :unzip_path => 'unzip',:force => true}
    options.update(user_opts)
    
    # find archives
    archives = []
    Find.find(File.expand_path(directory)) do |path|
      archives << File.expand_path(path) if File.file?(path) and path =~ /(\.tar$|\.bz2$|\.tar\.bz2$|\.tbz2$\|\.gz$|\.tar\.gz$|\.tgz$\|\.rar$|\.zip$)/
    end

    # figure out program and flags
    archives.each do |path|
      Dir.chdir(File.dirname(path))
      archive = File.basename(path)
      flags = []
      if archive =~ /\.tar$/ then
        flags += ['x','f']
        program = options[:tar_path]
      elsif archive =~ /\.bz2$/ then
        flags << 'd'
        flags << 'k' if options[:keep_archives]
        flags << 'f' if options[:force]
        program = options[:bzip2_path]
      elsif archive =~ /\.tar\.bz2$/ || archive =~ /\.tbz2$/ then
        # use `--bzip2' instead of `-j' for backwards compatibility; see
        # tar manual
        flags += ['x','f','-bzip2']
        program = options[:tar_path]
      elsif archive =~ /\.gz$/ then
        # use 'r' for recursive unzipping
        flags += ['d','r']
        flags << 'f' if options[:force]
        program = options[:gzip_path]
        # make a temporary copy under a different name so as to keep the
        # original archive (gzip lacks bzip2's `-k' option)
        FileUtils.cp(archive,archive+'copy',:verbose => options[:verbose]) if options[:keep_archives]
      elsif archive =~ /\.tar\.gz$/ || archive =~ /\.tgz$/ then
        flags += ['x','f','z']
        program = options[:tar_path]
      elsif archive =~ /\.rar$/ then
        flags << 'e'
        program = options[:unrar_path]
      elsif archive =~ /\.zip$/ then
        program = options[:unzip_path]
      end
      flags = ['v'] + flags if options[:verbose] # tar needs 'v' at
                                                 # the beginning of
                                                 # the list of options
      
      # construct command and decompress archive
      flags.map! {|flag| "-#{flag}"}
      command = "#{program} #{flags.join(' ')} #{archive}"
      unless options[:simulate] then
        raise IMW::SystemCallError.new("Couldn't extract #{archive} using #{program} (#{command})") unless system(command)
      else
        STDOUT.puts command
      end
      
      # manually delete tar and zip archives
      unless options[:keep_archives] then
        if archive =~ /\.(tar|zip)$/ then
          FileUtils.rm archive,:verbose => options[:verbose],:noop => options[:simulate]
        end
      end

      # manually delete tar.bz2 and tar.gz archives
      unless options[:keep_archives] then
        if archive =~ /(.*)\.(?:tar\.bz2|tar\.gz)$/ then
          unzipped_name = $1
        elsif archive =~ /(.*)\.(?tbz2|tgz)$/ then
          unzipped_name = $1 + '.tar'
        end
        FileUtils.rm(unzipped_name,:verbose => options[:verbose],:noop => options[:simulate])
      end

      # manually rename temporary copy back to original archive name for
      # the gzip case
      if options[:keep_archives] and archive =~ /\.gz$/
          FileUtils.mv archive + 'copy',archive,:verbose => options[:verbose], :noop => options[:simulate]
      end

    end
  end

  # Compress all the files in a given directory into a <tt>.tar.bz2</tt>
  # format.
  #
  # Any archives already in the directory will be extracted, deleted,
  # and their contents merged together in the final archive.
  # 
  # Options (with their default values in parentheses) include:
  # <tt>:simulate</tt> (false):: Show what would be done without doing it.
  # <tt>:delete_files</tt> (false):: Delete files after compressing them into the archive.
  # <tt>:keep_archives</tt> (false):: Keep any archives in the directory and do not decompress them before compressing the directory.
  # <tt>:verbose</tt> (false):: Print output.
  # <tt>:tar_path</tt> ('tar'):: Path to the tar program.
  # <tt>:bzip2_path</tt> ('bzip2'):: Path to the bzip2 program.
  def self.compress_directory(directory,user_opts={})

    # default options
    options = {:simulate => false, :delete_files => false, :keep_archives => false, :verbose => false}
    options.update(user_opts)
    
    # extract and delete any existent archives
    decompress_directory(directory,:simulate => options[:simulate], :verbose => options[:verbose]) unless options[:keep_archives]
    
    # make tarball
    flags = ['c','f']
    flags << 'v' if options[:verbose]
    flags.map! {|flag| '-#{flag}'}
    Dir.chdir(File.expand_path(directory))
    command = "#{options[:tar_path]} #{flags.join(' ')} #{File.basename(directory)}.tar *"
    unless options[:simulate] then
      raise IMW::SystemCallError.new("Couldn't create an archive of #{directory} using #{options[:tar_path]}.") unless system(command)
    else
      STDOUT.puts(command)
    end
    
    # compress it
    flags = []
    flags << 'v' if options[:verbose]
    flags.map! {|flag| '-#{flag}'}
    Dir.chdir(File.expand_path(directory))
    command = "#{options[:bzip2_path]} #{flags.join(' ')} #{File.basename(directory)}.tar"
    unless options[:simulate] then
      raise IMW::SystemCallError.new("Couldn't compress archive of #{directory}.tar using #{options[:bzip2_path]}.") unless system(command)
    else
      STDOUT.puts(command)
    end
    
    # delete all files
    if options[:delete_files] then
      only_file_to_keep = File.expand_path(directory) + File.basename(directory) + '.tar.bz2'
      Find.find(File.expand_path(directory)) do |path|
        unless options[:simulate] then
          FileUtils.rm(path,:verbose => options[:verbose]) unless path == only_file_to_keep
        else
          FileUtils.rm(path,:verbose => options[:verbose], :noop => true) unless path == only_file_to_keep
        end
      end
    end
  end

end


# puts "#{File.basename(__FILE__)}: You need a better filing cabinet in which to store your out-of-season Monkeywrenches.  Really, you do." # at bottom
