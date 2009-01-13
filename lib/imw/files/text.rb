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
    end

    FILE_REGEXPS[Regexp.new("\.txt$")] = IMW::Files::Text
    FILE_REGEXPS[Regexp.new("\.dat$")] = IMW::Files::Text
    FILE_REGEXPS[Regexp.new("\.ascii$")] = IMW::Files::Text        
  end
end

# puts "#{File.basename(__FILE__)}: Don't forget to put a nametag on your Monkeywrench or one of the other chimps might steal it!" # at bottom
