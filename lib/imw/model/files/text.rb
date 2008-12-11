#
# h2. lib/imw/model/files/text.rb -- describes text files
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

require 'imw/model/files/basicfile'
require 'imw/model/files/compressible'

module IMW
  module Files

    class Text

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path
        set_path path
      end

      def read
        File.read(File.expand_path(@path))
      end

    end
  end
end

# puts "#{File.basename(__FILE__)}: Don't forget to put a nametag on your Monkeywrench or one of the other chimps might steal it!" # at bottom
