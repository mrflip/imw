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
        :create => "-r",
        :append => "-g",
        :list => "-l",
        :extract => "-o",
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

      def archive_contents_string_to_array string
        # file information starts on fourth line of shell output and
        # there are two trailing lines which are useless
        file_rows = string.split("\n").slice(3,(output.size - 5)]
        file_rows.map! do |row|
          # the format is
          # 
          # 3  07-25-08 12:37   data/nested/awefawe.csv
          # 1002  07-25-08 12:12   data/nLbce.txt
          # 9  07-25-08 12:34   data/space file.txt
          #
          # and so we split each row at the space...columns beyond
          # the third are part of the filename and should be joined
          # with a space again in case of a filename with a space
          row.split(' ')[3,row.size].join(' ')
        end
        file_rows
      end
        
    end
  end
end

# puts "#{File.basename(__FILE__)}: You place your Monkeywrench into its custom-made case and zip it closed." # at bottom

