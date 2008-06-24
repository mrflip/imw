#
# h2. lib/imw/utils/stdlib_extensions.rb -- extensions to the ruby standard library
#
# == About
#
# Yes, the Ruby Standard Library is wonderful!  It's brilliant!
# But...it also lacks some convenient functions/idioms that are useful
# for the IMW.  So here they are!
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'
require 'imw/utils/config'
require 'imw/utils/error'

module FileUtils

  # Copies +sources+ to +dest+ with _smart_ default behavior.
  #
  # +sources+ can be a string naming a file or directory or an array
  # of such strings.  +dest+ is a directory in which to copy the
  # sources, which will be created if necessary.
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
  # Empty directories and empty files will not be copied.
  # Unrecognized options will be passed to <tt>FileUtils.cp</tt> and <tt>FileUtils.cp_r</tt>.

  def self.smart_copy(sources,dest,opts={})

    # deal with options...how i miss python...
    options = {}
    options[:dir_perms] = 0755
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
              until IMW::Yeses.member?(yn) or IMW::Nos.member?(yn) do
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
end


# puts "#{File.basename(__FILE__)}: Having swapped out its doodads, flumdiddles, and thingumadoodles for snazzier, up-market versions, your Monkeywrench is beginning to look quite swank!" # at bottom
