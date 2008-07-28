#
# h2. lib/imw/utils/random.rb -- creation of random objects
#
# == About
#
# This module has methods for creating random strings of text and
# random files in particular formats as well as random directories
# with random content.  These methods are most useful for testing.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'

require 'imw/utils'

module IMW

  module Random

    STRING_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ']
    TEXT_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ',"\n"]
    FILENAME_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + ["-","_"]
    EXTENSIONS = {
      /\.csv$/ => :csv_file,
      /\.xml$/ => :xml_file,
      /\.html$/ => :html_file,
      /\.tar$/ => :tar_file,
      /\.tar\.gz$/ => :targz_file,
      /\.tar\.bz2$/ => :tarbz2_file,
      /\.rar$/ => :rar_file,
      /\.zip$/ => :zip_file
    }

    private
    # Return a random filename of the given maximum +length+.
    def self.filename_without_extension(length = 9)
      # filenames shouldn't begin with a hyphen
      first_char = FILENAME_CHARS.random_element
      while first_char == '-' do
        first_char = FILENAME_CHARS.random_element
      end

      name = first_char
      rand(length).times { name +=  FILENAME_CHARS.random_element }
      name
    end

    # Return a random string of text up to the maximum +length+.
    def self.text_string length
      string = ""
      rand(length).times { string += STRING_CHARS.random_element }
      string
    end

    # Return a random paragraph of text up to the maximum +length+.
    def self.text_para length
      text = ""
      rand(length).times { text += TEXT_CHARS.random_element }
      text
    end

    public
    # Create a random file by matching the extension of the given
    # +filename+ or a text file if no match is found.
    def self.file filename
      match = EXTENSIONS.find { |regex,func| regex.match filename }
      match ? self.send(match.last,filename) : self.text_file(filename)
    end        

    # Create a random text file at +filename+ containing a maximum of
    # +length+ characters.
    def self.text_file(filename, length = 5000)
      f = File.open(filename,'w')
      f.write(text_para(length))
      f.close
    end

    # Create a comma-separated value file containing random text at
    # +filename+ with the maximum +num_rows+, the given +num_columns+,
    # and the maximum +entry_length+.
    def self.csv_file(filename,num_rows = 500, num_columns = 9, entry_length = 9)
      f = File.open(filename,'w')
      rand(num_rows).times do # rows
        num_columns.times do # columns
          f.write(text_string(entry_length)) # entry
          f.write ','
        end
        f.write(text_string(entry_length)) # last entry
        f.write("\n")
      end
      f.close
    end
    
    # Create an XML file at +filename+ of the maximum +length+.
    #
    # At the present moment, this file contains random text in a very
    # boring single-element XML tree.  Randomizing the tree has not
    # been implemented.
    def self.xml_file(filename, length = 5000)
      f = File.open(filename,'w')
      f.write "<xml>" + text_string(length) + "</xml>"
      f.close
    end

    # Create an HTML file at +filename+ of the maximum +length+.
    # 
    # At the present moment, this file contains random text in a very
    # boring bare-bones HTML with a single element body.  Randomizing
    # the tree has not been implemented.
    def self.html_file(filename, title_length = 100, body_length = 5000)
      f = File.open(filename,'w')
      f.write "<html><head><title>" + text_string(title_length) + "</title></head><body>" + text_string(body_length) + "</body></html>"
      f.close
    end

    # Create a tar archive at the given +filename+ containing random
    # files.
    def self.tar_file filename
      tmpd = File.dirname(filename) + '/dir'
      directory_with_files(tmpd)
      FileUtils.cd(tmpd) {|dir| IMW.system("#{IMW::EXTERNAL_PROGRAMS[:tar]} -cf file.tar *") }
      FileUtils.cp(tmpd + "/file.tar",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Create a tar.gz archive at the given +filename+ containing
    # random files.
    def self.targz_file filename
      tar = File.dirname(filename) + "/file.tar"
      targz = tar + ".gz"
      tar_file tar
      IMW.system("#{IMW::EXTERNAL_PROGRAMS[:gzip]} #{tar}")
      FileUtils.cp(targz,filename)
      FileUtils.rm(targz)
    end

    # Create a tar.bz2 archive at the given +filename+ containing
    # random files.
    def self.tarbz2_file filename
      tar = File.dirname(filename) + "/file.tar"
      tarbz2 = tar + ".bz2"
      tar_file tar
      IMW.system("#{IMW::EXTERNAL_PROGRAMS[:bzip2]} #{tar}")
      FileUtils.cp(tarbz2,filename)
      FileUtils.rm(tarbz2)
    end

    # Create a compressed rar archive at the given +filename+
    # containing random files.
    def self.rar_file filename
      tmpd = File.dirname(filename) + '/dir'
      directory_with_files(tmpd)
      FileUtils.cd(tmpd) {|dir| IMW.system("#{IMW::EXTERNAL_PROGRAMS[:rar]} a -r -o+ file.rar *") }
      FileUtils.cp(tmpd + "/file.rar",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Create a compressed zip archive at the given +filename+
    # containing random files.
    def self.zip_file filename
      tmpd = File.dirname(filename) + '/dir'
      directory_with_files(tmpd)
      FileUtils.cd(tmpd) {|dir| IMW.system("#{IMW::EXTERNAL_PROGRAMS[:zip]} -r file.zip *") }
      FileUtils.cp(tmpd + "/file.zip",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Creates +directory+ and fills it with random files containing
    # random data.
    #
    # Options (with their default values in parentheses) include:
    #
    # <tt>:extensions</tt> (<tt>[txt,csv,dat,xml]</tt>):: extensions to use.  If an extension is known (see <tt>IMW::Test::EXTENSIONS</tt>) then appropriately formatted random data will be used  If an extension is not known, it will be treated as text.  The extension +dir+ will create a directory which will itself be filled with random files in the same way as its parent.
    # <tt>:max_depth</tt> (3):: maximum depth to nest directories
    # <tt>:starting_depth</tt> (1):: the default depth the parent directory is assumed to have
    # <tt>:num_files</tt> (10):: the maximum number of files per directory
    # <tt>:force</tt> (false):: force overwriting of existing directories
    def self.directory_with_files(directory,options = {})
      options.reverse_merge!({:extensions => ['txt','csv','dat','xml'],:max_depth => 3,:force => false,:starting_depth => 1, :num_files => 3})
      depth = options[:starting_depth]

      if File.exist?(directory) then
        if options[:force] then
          FileUtils.rm_rf(directory)
        else
          IMW::Error.new("#{directory} already exists")
        end
      end
      FileUtils.mkdir_p(directory)
      
      (rand(options[:num_files]) + 2).times do
        ext = options[:extensions].random_element
        name = filename_without_extension
        if ext == 'dir' then
          if depth <= options[:max_depth] then
            newd = directory + '/' + name
            FileUtils.mkdir(newd)
            directory_with_files(newd,options.merge({:starting_depth => (depth + 1)}))
          else
            next
          end
        else
          file(directory + '/' + name + '.' + ext)
        end
      end
    end


  end
end


# puts "#{File.basename(__FILE__)}: You hurl your Monkeywrench at a passerby to test whether he'll flinch.  He doesn't.  You'd better run..." # at bottom
