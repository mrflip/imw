#
# h2. lib/imw/files/text.rb -- describes text files
#
# == About
#
# Base class for text files of various types to subclass from.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/files/basicfile'
require 'imw/files/compressible'

module IMW
  module Files

    class Text < File

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path, mode='r', options = {}
        self.path= path
        super path, mode
      end

      # Return the contents of this text file as a string.  If given a
      # block, then pass each line of the string to the block.
      def load &block
        f = File.new(@path)
        if block
          f.each_line {|line| yield line}
        else
          f.read
        end
      end

      # Dump +data+ to this file as a string.
      #
      # FIXME should we worry about the fact that this is ugly for
      # nested Ruby structures?
      def dump data
        File.open(@path,'w') {|f| f.write(data)}
      end

    end

    FILE_REGEXPS << [/\.txt$/,   IMW::Files::Text]
    FILE_REGEXPS << [/\.dat$/,   IMW::Files::Text]
    FILE_REGEXPS << [/\.ascii$/, IMW::Files::Text]
    
  end
end

# puts "#{File.basename(__FILE__)}: Don't forget to put a nametag on your Monkeywrench or one of the other chimps might steal it!" # at bottom
