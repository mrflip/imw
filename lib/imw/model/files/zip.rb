#
# h2. lib/imw/model/files/zip.rb -- describes a zip file
#
# == About
#
# Class for describing a compressed zip archive.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/file'
require 'imw/model/files/archive'

require 'imw/utils'

module IMW

  module Files

    class Zip < IMW::Files::File

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
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a zip file.") unless @extname == '.zip'
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
        
    end
  end
end

# puts "#{File.basename(__FILE__)}: You place your Monkeywrench into its custom-made case and zip it closed." # at bottom

