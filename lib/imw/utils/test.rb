#
# h2. lib/imw/utils/test.rb -- routines useful for testing
#
# == About
#
# Testing requires setting up environments and these functions ease
# that process.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/core_extensions'
require 'imw/utils/fileutils_extensions'
require 'imw/utils/error'
require 'fileutils'

module IMW
  module Test

    RandomCharacters = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ']
    RandomizeableExtensions = ['csv','xml','tar','tar.gz','tar.bz2','html']

    # Creates +directory+ and fills it with random files containing
    # random data.
    #
    # Options (with their default values in parentheses) include:
    #
    # <tt>:extensions</tt> (<tt>[txt,csv,dat,xml]</tt>):: extensions to use.  If an extension is known (see <tt>IMW::Test::RandomizableExtensions</tt> for a list) then appropriately formatted random data will be used  If an extension is not known, it will be treated as text.  The extension +dir+ will create a directory which will itself be filled with random files in the same way as it's parent.
    # <tt>:max_depth</tt> (3):: maximum depth to next directories and archives
    # <tt>:force</tt> (false):: force overwriting of existent directories
    #
    def self.random_data_in_directory(directory,starting_depth=1,user_opts={})
      depth = starting_depth
      directory = File.expand_path(directory)

      options = {:extensions => ['txt','csv','dat','xml'],:max_depth => 3,:force => false}
      options.update(user_opts)

      begin
        FileUtils.mkdir(directory)
      rescue Errno::EEXIST
        if options[:force] then
          FileUtils.rm_rf(directory)
          FileUtils.mkdir(directory)
        else
          raise IMW::Error.new("#{directory} already exists")
        end
      end
      
      (rand(10) + 2).times do
        ext = options[:extensions].random_element
        name = random_filename_without_extension
        filename = directory + '/' + name + '.' + ext
        case ext
        when 'csv'
          random_csv(filename)
        when 'xml'
          random_xml(filename)
        when 'tar'
          random_tar(filename)
        when 'tar.gz'
          random_targz(filename)
        when 'tar.bz2'
          random_tarbz2(filename)
        when 'html'
          random_html(filename)
        when 'dir'
          if depth <= options[:max_depth] then
            newd = directory + '/' + name
            FileUtils.mkdir(newd)
            random_data_in_directory(newd,depth + 1,options)
          else
            next
          end
        else
          random_text(filename)
        end
      end
    end

    # Return a random filename
    def self.random_filename_without_extension
      name = ''
      (rand(9) + 1).times do
        char = RandomCharacters.random_element
        while char == ' ' do
          # don't want spaces in filenames
          char = RandomCharacters.random_element
        end
        name << char
      end
      name
    end
    
    # Create a file containing random text at +filename+
    def self.random_text(filename)
      f = File.open(filename,'w')
      rand(5000).times do
        f.write RandomCharacters.random_element
      end
      f.close
    end

    # Create a comma-separated value file containing random text at +filename+
    def self.random_csv(filename)
      f = File.open(filename,'w')
      rand(500).times do # rows
        9.times do # columns
          9.times {f.write RandomCharacters.random_element } # entry
          f.write ','
        end
        9.times {f.write RandomCharacters.random_element } # last entry
        f.write("\n")
      end
      f.close
    end
    
    # Create an XML file containing random text at +filename+.
    #
    # At the present moment, this file contains random text in a very
    # boring single-element XML tree.  Randomizing the tree has not
    # been implemented.
    def self.random_xml(filename)
      f = File.open(filename,'w')
      f.write "<xml>"
      rand(5000).times do
        f.write RandomCharacters.random_element
      end
      f.write "</xml>"
      f.close
    end

    # Create an HTML file containing random text at +filename+.
    # 
    # At the present moment, this file contains random text in a very
    # boring bare-bones HTML with a single element body.  Randomizing
    # the tree has not been implemented.
    def self.random_html(filename)
      f = File.open(filename,'w')
      f.write "<html><head><title>"
      rand(100).times do
        f.write RandomCharacters.random_element
      end
      f.write "</title></head><body>"
      rand(5000).times do
        f.write RandomCharacters.random_element
      end
      f.write "</body></html>"
      f.close
    end

    # Create a tar archive at the given +filename+ containing random
    # files.
    def self.random_tar(filename)
      tmpd = filename + '.dir'
      random_data_in_directory(tmpd)
      Dir.chdir(tmpd)
      system("tar -cf #{filename} *")
      FileUtils.rm_rf(tmpd)
    end

    # Create a tar.gz archive at the given +filename+ containing
    # random files.
    def self.random_targz(filename)
      # filename already has gz suffix so should be stripped
      filename = filename[0,filename.length - '.gz'.length]
      random_tar(filename)
      system("gzip #{filename}")
    end

    # Create a tar.bz2 archive at the given +filename+ containing
    # random files.
    def self.random_tarbz2(filename)
      # filename already has bz2 suffix so should be stripped      
      filename = filename[0,filename.length - '.bz2'.length]      
      random_tar(filename)
      system("bzip2 #{filename}")
    end

  end

end
      
# puts "#{File.basename(__FILE__)}: You hurl your Monkeywrench at a passerby to test whether he'll flinch.  He doesn't.  You'd better run..." # at bottom
