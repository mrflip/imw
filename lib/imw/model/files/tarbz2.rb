#
# h2. lib/imw/model/files/tarbz2.rb -- describes a tar.bz2 file
#
# == About
#
# Class for describing a tar.bz2 file, a tar archive compressed with
# bzip2.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/compressed_file'

require 'imw/utils'

module IMW

  module Files

    class TarBz2 < IMW::Files::CompressedFile

      DEFAULT_FLAGS = {
        :decompression => '-fd',
        :list => "-tf",
        :extract => "-xjf"
      }

      def initialize path
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a tar.bz2 compressed archive.") unless /(\.tar\.bz2$|\.tbz2$)/.match @path
        @compression = {
          :program => :bzip2,
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
        @archive = {
          :program => :tar,
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract]
        }
      end

      # Returns the path of the file after decompression.
      def decompressed_file
        if /\.tar\.bz2$/.match @path then
          @path.gsub /\.tar\.bz2$/ ".tar"
        elsif /\.tbz2$/.match @path then
          @path.gsub /\.tbz2$/ ".tar"
        end
      end

    end
    
  end
  
end

# puts "#{File.basename(__FILE__)}: Am I the only monkey frustrated by the fact that .tar.bz2 and .tbz2 are synonymous?" # at bottom

