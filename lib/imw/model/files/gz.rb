#
# h2. lib/imw/model/files/gz.rb -- describes a gzipped file
#
# == About
#
# Class for describing a gzip-compressed file.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/compressed_file'

module IMW

  module Files

    class Gz < IMW::Files::CompressedFile

      DEFAULT_FLAGS = { :decompression => '-fd' }

      def initialize path
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a gzip compressed file.") unless @extname == '.gz'
        @compression = {
          :program => :gzip,
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
      end

      def decompressed_path
        @path.gsub /\.gz$/, ""
      end

    end
  end
end

# puts "#{File.basename(__FILE__)}: I've always thought that G-Zip would be great name for a rapper." # at bottom
