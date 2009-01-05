#
# h2. lib/imw/model/files/compressed_files_and_archives.rb -- require farm
#
# == About
#
# Just required all the archive and compressed formats (+tar+, +bz2+,
# &c.)
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/model/files/basicfile'
require 'imw/model/files/compressible'
require 'imw/model/files/archive'
require 'imw/model/files/compressed_file'

module IMW
  module Files

    include IMW::Files::BasicFile
    include IMW::Files::Archive
    include IMW::Files::Compressible
    
    # A class to model a +tar+ archive.  Created with a single
    # argument, the path to the file.
    #
    # Creation, appending, listing, and extraction flags are stored in
    # <tt>IMW::Files::Tar::DEFAULT_FLAGS</tt> and all are passed to
    # the <tt>:tar</tt> program in <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class Tar
      # The default flags used creating, appending to, listing, and
      # extracting a tar archive.
      DEFAULT_FLAGS = {
        :create => "-cf",
        :append => "-rf",
        :list => "-tf",
        :extract => "-xf",
        :program => :tar
      }
      
      def initialize path
        self.path= path
        @archive = {
          :program => DEFAULT_FLAGS[:program],
          :create_flags => DEFAULT_FLAGS[:create],
          :append_flags => DEFAULT_FLAGS[:append],
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract]
        }
      end
    end # Tar

    # A class to model a <tt>tar.gz</tt> archive.  Created with a
    # single argument, the path to the file.
    #
    # Creation, appending, listing, and extraction flags are stored in
    # <tt>IMW::Files::TarGz::DEFAULT_FLAGS</tt> and all are passed to
    # the <tt>:tar</tt> program in <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class TarGz

      include IMW::Files::BasicFile
      include IMW::Files::Archive
      include IMW::Files::CompressedFile

      # The default flags used creating, appending to, listing, and
      # extracting a <tt>tar.gz</tt> archive.
      DEFAULT_FLAGS = {
        :decompression_program => :gzip,
        :decompression_flags => '-fd',
        :archive_program => :tar,
        :archive_list_flags => "-tf",
        :archive_extract_flags => "-xzf"
      }

      def initialize path
        self.path= path
        @compression = {
          :program => DEFAULT_FLAGS[:decompression_program],
          :decompression_flags => DEFAULT_FLAGS[:decompression_flags]
        }
        @archive = {
          :program => DEFAULT_FLAGS[:archive_program],
          :list_flags => DEFAULT_FLAGS[:archive_list_flags],
          :extract_flags => DEFAULT_FLAGS[:archive_extract_flags]
        }
      end

      # Returns the path of the file after decompression.
      def decompressed_path
        if /\.tar\.gz$/.match @path then
          @path.gsub /\.tar\.gz$/, ".tar"
        elsif /\.tgz$/.match @path then
          @path.gsub /\.tgz$/, ".tar"
        end
      end
    end # TarGz

    # A class to model a <tt>tar.bz2</tt> archive.  Created with a
    # single argument, the path to the file.
    #
    # Creation, appending, listing, and extraction flags are stored in
    # <tt>IMW::Files::TarBz2::DEFAULT_FLAGS</tt> and all are passed to
    # the <tt>:tar</tt> program in <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class TarBz2

      include IMW::Files::BasicFile
      include IMW::Files::Archive
      include IMW::Files::CompressedFile

      # The default flags used creating, appending to, listing, and
      # extracting a <tt>tar.bz2</tt> archive.
      DEFAULT_FLAGS = {
        :decompression_program => :bzip2,
        :decompression_flags => '-fd',
        :archive_program => :tar,
        :archive_list_flags => "-tf",
        :archive_extract_flags => "-xjf"
      }

      def initialize path
        self.path= path
        @compression = {
          :program => DEFAULT_FLAGS[:decompression_program],
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
        @archive = {
          :program => DEFAULT_FLAGS[:archive_program],
          :list_flags => DEFAULT_FLAGS[:archive_list_flags],
          :extract_flags => DEFAULT_FLAGS[:archive_extract_flags]
        }
      end

      # Returns the path of the file after decompression.
      def decompressed_path
        if /\.tar\.bz2$/.match @path then
          @path.gsub /\.tar\.bz2$/, ".tar"
        elsif /\.tbz2$/.match @path then
          @path.gsub /\.tbz2$/, ".tar"
        end
      end
    end # TarBz2
    
    # A class to model a +rar+ archive.  Created with a single
    # argument, the path to the file.
    #
    # Creation, appending, listing, and extraction flags are stored in
    # <tt>IMW::Files::Rar::DEFAULT_FLAGS</tt> and all are passed to
    # the <tt>:rar</tt> program in <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class Rar
      
      include IMW::Files::BasicFile
      include IMW::Files::Archive
      
      # The default flags used creating, appending to, listing, and
      # extracting a rar archive.
      DEFAULT_FLAGS = {
        :create => "a -r -o+ -inul",
        :append => "a -r -o+ -inul",
        :list => "vb",
        :extract => "x -o+ -inul"
      }
      
      def initialize path
        self.path= path
        @archive = {
          :program => :rar,
          :create_flags => DEFAULT_FLAGS[:create],
          :append_flags => DEFAULT_FLAGS[:append],
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract]
        }
      end
    end # Rar

    # A class to model a +zip+ archive.  Created with a single
    # argument, the path to the file.
    #
    # Creation, appending, listing, and extraction flags are stored in
    # <tt>IMW::Files::Zip::DEFAULT_FLAGS</tt> and all are passed to
    # the <tt>:zip</tt> and <tt>:unzip</tt> programs in
    # <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class Zip
      
      include IMW::Files::BasicFile
      include IMW::Files::Archive
      
      # The default flags used creating, appending to, listing, and
      # extracting a zip archive.
      DEFAULT_FLAGS = {
        :create => "-r -q",
        :append => "-g -q",
        :list => "-l",
        :extract => "-o -q",
        :unarchiving_program => :unzip
      }
      
      def initialize path
        self.path= path
        @archive = {
          :program => :zip,
          :create_flags => DEFAULT_FLAGS[:create],
          :append_flags => DEFAULT_FLAGS[:append],
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract],
          :unarchiving_program => DEFAULT_FLAGS[:unarchiving_program]
        }
      end

      # The `unzip' program outputs data in a very annoying format:
      #
      #     Archive:  data.zip
      #       Length     Date   Time    Name
      #      --------    ----   ----    ----
      #         18510  07-28-08 15:58   data/4d7Qrgz7.csv
      #          3418  07-28-08 15:41   data/7S.csv
      #         23353  07-28-08 15:41   data/g.csv
      #           711  07-28-08 15:58   data/g.xml
      #          1095  07-28-08 15:41   data/L.xml
      #          2399  07-28-08 15:58   data/mTAu9H3.xml
      #           152  07-28-08 15:58   data/vaHBS2t5R.dat
      #      --------                   -------
      #         49638                   7 files
      #
      # which is parsed by this method.
      def archive_contents_string_to_array string
        rows = string.split("\n")
        # ignore the first 3 lines of the output and also discared the
        # last 2 (5 = 2 + 3)
        file_rows = rows[3,(rows.length - 5)]
        file_rows.map! do |row|
          # discard extra whitespace before after main text
          row.lstrip!.rstrip!
          # split the remainig text at spaces...columns beyond the third
          # are part of the filename and should be joined with a space
          # again in case of a filename with a space
          row.split(' ')[3,row.size].join(' ')
        end
        file_rows
      end
    end # Zip

    # A class to model a <tt>gz</tt> compressed file.  Created with a
    # single argument, the path to the file.
    #
    # The decompressing flags are stored in
    # <tt>IMW::Files::Gz::DEFAULT_FLAGS</tt> and all are passed to the
    # <tt>:gzip</tt> program in <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class Gz

      include IMW::Files::BasicFile
      include IMW::Files::CompressedFile

      # The default flags used in extracting a <tt>gz</tt> file.
      DEFAULT_FLAGS = {
        :program => :gzip,
        :decompression => '-fd'
      }

      def initialize path
        self.path= path
        @compression = {
          :program => DEFAULT_FLAGS[:program],
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
      end

      def decompressed_path
        @path.gsub /\.gz$/, ""
      end
    end # Gz

    # A class to model a <tt>bz2</tt> compressed file.  Created with a
    # single argument, the path to the file.
    #
    # The decompressing flags are stored in
    # <tt>IMW::Files::Bz2::DEFAULT_FLAGS</tt> and all are passed to
    # the <tt>:bzip2</tt> program in <tt>IMW::EXTERAL_PROGRAMS</tt>.
    class Bz2

      include IMW::Files::BasicFile
      include IMW::Files::CompressedFile

      # The default flags used in extracting a <tt>bz2</tt> file.
      DEFAULT_FLAGS = {
        :program => :bzip2,
        :decompression => '-fd'
      }

      def initialize path
        self.path= path
        raise IMW::Error.new("#{@extname} is not a valid extension for a bzip2 compressed file.") unless @extname == '.bz2'
        @compression = {
          :program => DEFAULT_FLAGS[:program],
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
      end

      # Returns the path of the file after decompression.
      def decompressed_path
        @path.gsub /\.bz2$/, ""
      end
    end # Bz2

    FILE_REGEXPS[Regexp.new("\.bz2$")]      = IMW::Files::Bz2
    FILE_REGEXPS[Regexp.new("\.gz$")]       = IMW::Files::Gz
    FILE_REGEXPS[Regexp.new("\.tar$")]      = IMW::Files::Tar
    FILE_REGEXPS[Regexp.new("\.tar\.bz2$")] = IMW::Files::TarBz2
    FILE_REGEXPS[Regexp.new("\.tbz2$")]     = IMW::Files::TarBz2
    FILE_REGEXPS[Regexp.new("\.tar\.gz$")]  = IMW::Files::TarGz
    FILE_REGEXPS[Regexp.new("\.tgz$")]      = IMW::Files::TarGz
    FILE_REGEXPS[Regexp.new("\.rar$")]      = IMW::Files::Rar
    FILE_REGEXPS[Regexp.new("\.zip$")]      = IMW::Files::Zip
    
  end # Files
end # IMW


