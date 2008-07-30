#
# h2. lib/imw/model/files/targz.rb -- describes a tar.gz file
#
# == About
#
# Class for describing a tar.gz file, a tar archive compressed with
# gzip.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/compressed_file'
require 'imw/model/files/archive'
require 'imw/utils'

module IMW

  module Files

    class TarGz < IMW::Files::CompressedFile

      include IMW::Files::Archive

      DEFAULT_FLAGS = {
        :decompression => '-fd',
        :list => "-tf",
        :extract => "-xzf"
      }

      def initialize path
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a tar.gz compressed archive.") unless /(\.tar\.gz$|\.tgz$)/.match @path
        @compression = {
          :program => :gzip,
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
        @archive = {
          :program => :tar,
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract]
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

    end
    
  end
  
end

# puts "#{File.basename(__FILE__)}: Am I the only monkey frustrated by the fact that .tar.gz and .tgz are synonymous?" # at bottom

