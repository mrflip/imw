#
# h2. lib/imw/model/files/bz2.rb -- describes a bz2 file
#
# == About
#
# Class for describing a bzip2 compressed file.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/compressed_file'

module IMW

  module Files

    class Bz2 < IMW::Files::CompressedFile

      DEFAULT_FLAGS = { :decompression => '-fd' }

      def initialize path
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a bzip2 compressed file.") unless @extname == '.bz2'
        @compression = {
          :program => :bzip2,
          :decompression_flags => DEFAULT_FLAGS[:decompression]
        }
      end

      # Returns the path of the file after decompression.
      def decompressed_path
        @path.gsub /\.bz2$/, ""
      end
      
    end

  end

end

# puts "#{File.basename(__FILE__)}: Your Monkeywrench is a lot smaller than you remember it being.  Maybe it'll grow if you soak it for a while?" # at bottom
