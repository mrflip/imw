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

require 'imw/model/files/file'
require 'imw/model/files/compressible'

module IMW
  module Files

    class Text < IMW::Files::File

      include IMW::Files::Compressible
      
    end
  end
end

# puts "#{File.basename(__FILE__)}: Don't forget to put a nametag on your Monkeywrench or one of the other chimps might steal it!" # at bottom
