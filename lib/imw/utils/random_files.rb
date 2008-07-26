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

require 'fileutils'

require 'imw/utils/error'
require 'imw/utils/core_extensions'
require 'imw/utils/config'

module IMW

  module Test

    STRING_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ']
    TEXT_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ',"\n"]
    FILENAME_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + ["-","_"]
    EXTENSIONS = {
      /\.csv$/ => :random_csv,
      /\.xml$/ => :random_xml,
      /\.html$/ => :random_html,
      /\.tar$/ => :random_tar,
      /\.tar\.gz$/ => :random_targz,
      /\.tar\.bz2$/ => :random_tarbz2,
      /\.rar$/ => :random_rar,
      /\.zip$/ => :random_zip
    }

    private
    # Return a random filename of the given maximum +length+.
    def self.random_filename_without_extension(length = 9)
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
    def self.random_text_string length
      string = ""
      rand(length).times { string += STRING_CHARS.random_element }
      string
    end

    # Return a random paragraph of text up to the maximum +length+.
    def self.random_text_para length
      text = ""
      rand(length).times { text += TEXT_CHARS.random_element }
      text
    end

    public
    # Create a random file by matching the extension of the given
    # +filename+ or a text file if no match is found.
    def self.random_file filename
      match = EXTENSIONS.find { |regex,func| regex.match filename }
      match ? self.send(match.last,filename) : self.random_text(filename)
    end        

    # Create a random text file at +filename+ containing a maximum of
    # +length+ characters.
    def self.random_text(filename, length = 5000)
      f = File.open(filename,'w')
      f.write(random_text_para(length))
      f.close
    end

    # Create a comma-separated value file containing random text at
    # +filename+ with the maximum +num_rows+, the given +num_columns+,
    # and the maximum +entry_length+.
    def self.random_csv(filename,num_rows = 500, num_columns = 9, entry_length = 9)
      f = File.open(filename,'w')
      rand(num_rows).times do # rows
        num_columns.times do # columns
          f.write(random_text_string(entry_length)) # entry
          f.write ','
        end
        f.write(random_text_string(entry_length)) # last entry
        f.write("\n")
      end
      f.close
    end
    
    # Create an XML file at +filename+ of the maximum +length+.
    #
    # At the present moment, this file contains random text in a very
    # boring single-element XML tree.  Randomizing the tree has not
    # been implemented.
    def self.random_xml(filename, length = 5000)
      f = File.open(filename,'w')
      f.write "<xml>" + random_text_string(length) + "</xml>"
      f.close
    end

    # Create an HTML file at +filename+ of the maximum +length+.
    # 
    # At the present moment, this file contains random text in a very
    # boring bare-bones HTML with a single element body.  Randomizing
    # the tree has not been implemented.
    def self.random_html(filename, title_length = 100, body_length = 5000)
      f = File.open(filename,'w')
      f.write "<html><head><title>" + random_text_string(title_length) + "</title></head><body>" + random_text_string(body_length) + "</body></html>"
      f.close
    end

    # Create a tar archive at the given +filename+ containing random
    # files.
    def self.random_tar filename
      tmpd = File.dirname(filename) + '/dir'
      random_directory(tmpd)
      FileUtils.cd(tmpd) {|dir| IMW.system("#{IMW::EXTERNAL_PROGRAMS[:tar]} -cf file.tar *") }
      FileUtils.cp(tmpd + "/file.tar",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Create a tar.gz archive at the given +filename+ containing
    # random files.
    def self.random_targz filename
      tar = File.dirname(filename) + "/file.tar"
      targz = tar + ".gz"
      random_tar tar
      IMW.system("#{IMW::EXTERNAL_PROGRAMS[:gzip]} #{tar}")
      FileUtils.cp(targz,filename)
      FileUtils.rm(targz)
    end

    # Create a tar.bz2 archive at the given +filename+ containing
    # random files.
    def self.random_tarbz2 filename
      tar = File.dirname(filename) + "/file.tar"
      tarbz2 = tar + ".bz2"
      random_tar tar
      IMW.system("#{IMW::EXTERNAL_PROGRAMS[:bzip2]} #{tar}")
      FileUtils.cp(tarbz2,filename)
      FileUtils.rm(tarbz2)
    end

    # Create a compressed rar archive at the given +filename+
    # containing random files.
    def self.random_rar filename
      tmpd = File.dirname(filename) + '/dir'
      random_directory(tmpd)
      FileUtils.cd(tmpd) {|dir| IMW.system("#{IMW::EXTERNAL_PROGRAMS[:rar]} a -r -o+ file.rar *") }
      FileUtils.cp(tmpd + "/file.rar",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Create a compressed zip archive at the given +filename+
    # containing random files.
    def self.random_zip filename
      tmpd = File.dirname(filename) + '/dir'
      random_directory(tmpd)
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
    def self.random_directory(directory,options = {})
      options.reverse_merge!({:extensions => ['txt','csv','dat','xml'],:max_depth => 3,:force => false,:starting_depth => 1, :num_files => 10})
      depth = options[:starting_depth]

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
      
      (rand(options[:num_files]) + 2).times do
        ext = options[:extensions].random_element
        name = random_filename_without_extension
        if ext == 'dir' then
          if depth <= options[:max_depth] then
            newd = directory + '/' + name
            FileUtils.mkdir(newd)
            random_directory(newd,options.merge({:starting_depth => (depth + 1)}))
          else
            next
          end
        else
          random_file(directory + '/' + name + '.' + ext)
        end
      end
    end


  end

end
      
# puts "#{File.basename(__FILE__)}: You hurl your Monkeywrench at a passerby to test whether he'll flinch.  He doesn't.  You'd better run..." # at bottom
