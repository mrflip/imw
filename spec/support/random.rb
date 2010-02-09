require 'fileutils'

module IMWTest
  module Random

    STRING_CHARS        = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ']
    TEXT_CHARS          = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + [' ',' ',' ',' ',' ',"\n"]
    FILENAME_CHARS      = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + ["-","_",' ']
    FILENAME_MAX_LENGTH = 9
    TEXT_MAX_LENGTH     = 1024
    EXTENSIONS          = {
      /\.csv$/      => :csv_file,
      /\.xml$/      => :xml_file,
      /\.html$/     => :html_file,
      /\.tar$/      => :tar_file,
      /\.tar\.gz$/  => :targz_file,
      /\.tar\.bz2$/ => :tarbz2_file,
      /\.rar$/      => :rar_file,
      /\.zip$/      => :zip_file
    }
    EXTERNAL_PROGRAMS = if defined?(IMW) && defined?(IMW::EXTERNAL_PROGRAMS)
                          IMW::EXTERNAL_PROGRAMS
                        else
                          {
        :tar => "tar",
        :rar => "rar",
        :zip => "zip",
        :unzip => "unzip",
        :gzip => "gzip",
        :bzip2 => "bzip2",
        :wget => "wget"
      }
                        end

    private
    # Return a random filename.  Optional +length+ to set the maximum
    # length of the filename returned.
    def self.basename options = {}
      length = (options[:length] or FILENAME_MAX_LENGTH)
      filename = (1..length).map { |i| FILENAME_CHARS.random }.join

      # filenames beginning with hyphens suck
      while (filename[0,1] == '-') do
        filename[0] = FILENAME_CHARS.random
      end
      filename
    end
    
    # Return a random string of text up.  Control the length with
    # optional +length+ and also the presence of +newlines+.
    def self.text options = {}
      length = (options[:length] or TEXT_MAX_LENGTH)
      char_pool = options[:newlines] ? TEXT_CHARS : STRING_CHARS
      (1..length).map { |i| char_pool.random }.join
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
    def self.text_file filename, options = {}
      File.open(filename,'w') { |f| f.write text(:newlines => true) }
    end

    # Create a comma-separated value file containing random text at
    # +filename+ with the maximum +num_rows+, the given +num_columns+,
    # and the maximum +entry_length+.
    def self.csv_file(filename,num_rows = 500, num_columns = 9, entry_length = 9)
      f = File.open(filename,'w')
      rand(num_rows).times do # rows
        num_columns.times do # columns
          f.write(text(:length => entry_length)) # entry
          f.write ','
        end
        f.write(text(:length => entry_length)) # last entry
        f.write("\n")
      end
      f.close
    end
    
    # Create an XML file at +filename+ of the maximum +length+.
    #
    # At the present moment, this file contains random text in a very
    # boring single-element XML tree.  Randomizing the tree has not
    # been implemented.
    def self.xml_file filename, options = {}
      options = options.reverse_merge({:max_depth => 5, :starting_depth => 1, :depth => nil, :pretty_print => true})
      File.open(filename,'w') do |file|
        file.write "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        file.write "<xml>" + text + "</xml>"
        file.close
      end
    end
    

    # Create an HTML file at +filename+ of the maximum +length+.
    # 
    # At the present moment, this file contains random text in a very
    # boring bare-bones HTML with a single element body.  Randomizing
    # the tree has not been implemented.
    def self.html_file(filename, title_length = 100, body_length = 5000)
      f = File.open(filename,'w')
      f.write "<html><head><title>" + string(title_length) + "</title></head><body>" + string(body_length) + "</body></html>"
      f.close
    end

    # Create a tar archive at the given +filename+ containing random
    # files.
    def self.tar_file filename
      tmpd = File.dirname(filename) + '/dir'
      directory_with_files(tmpd)
      FileUtils.cd(tmpd) {|dir| system("#{EXTERNAL_PROGRAMS[:tar]} -cf file.tar *") }
      FileUtils.cp(tmpd + "/file.tar",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Create a tar.gz archive at the given +filename+ containing
    # random files.
    def self.targz_file filename
      tar = File.dirname(filename) + "/file.tar"
      targz = tar + ".gz"
      tar_file tar
      system("#{EXTERNAL_PROGRAMS[:gzip]} #{tar}")
      FileUtils.cp(targz,filename)
      FileUtils.rm(targz)
    end

    # Create a tar.bz2 archive at the given +filename+ containing
    # random files.
    def self.tarbz2_file filename
      tar = File.dirname(filename) + "/file.tar"
      tarbz2 = tar + ".bz2"
      tar_file tar
      system("#{EXTERNAL_PROGRAMS[:bzip2]} #{tar}")
      FileUtils.cp(tarbz2,filename)
      FileUtils.rm(tarbz2)
    end

    # Create a compressed rar archive at the given +filename+
    # containing random files.
    def self.rar_file filename
      tmpd = File.dirname(filename) + '/dir'
      directory_with_files(tmpd)
      FileUtils.cd(tmpd) {|dir| system("#{EXTERNAL_PROGRAMS[:rar]} a -r -o+ file.rar *") }
      FileUtils.cp(tmpd + "/file.rar",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Create a compressed zip archive at the given +filename+
    # containing random files.
    def self.zip_file filename
      tmpd = File.dirname(filename) + '/dir'
      directory_with_files(tmpd)
      FileUtils.cd(tmpd) {|dir| system("#{EXTERNAL_PROGRAMS[:zip]} -r file.zip *") }
      FileUtils.cp(tmpd + "/file.zip",filename)
      FileUtils.rm_rf(tmpd)
    end

    # Creates +directory+ and fills it with random files containing
    # random data.
    #
    # Options (with their default values in parentheses) include:
    #
    # <tt>:extensions</tt> (<tt>[txt,csv,dat,xml]</tt>):: extensions to use.  If an extension is known (see <tt>IMWTest::Random::EXTENSIONS</tt>) then appropriately formatted random data will be used  If an extension is not known, it will be treated as text.  The extension +dir+ will create a directory which will itself be filled with random files in the same way as its parent.
    # <tt>:max_depth</tt> (3):: maximum depth to nest directories
    # <tt>:starting_depth</tt> (1):: the default depth the parent directory is assumed to have
    # <tt>:num_files</tt> (10):: the maximum number of files per directory
    # <tt>:force</tt> (false):: force overwriting of existing directories
    def self.directory_with_files(directory,options = {})
      directory = File.expand_path(directory)
      options = options.reverse_merge({:extensions => ['txt','csv','dat'],:max_depth => 3,:force => false,:starting_depth => 1, :num_files => 3})
      depth = options[:starting_depth]

      if File.exist?(directory) then
        if options[:force] then
          FileUtils.rm_rf(directory)
        else
          raise "#{directory} already exists"
        end
      end
      FileUtils.mkdir_p(directory)

      (rand(options[:num_files]) + 2).times do
        ext = options[:extensions].random
        name = self.basename
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



