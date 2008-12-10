#
# h2. lib/imw/model/files/binary.rb -- binary files
#
# == About
#
# Class for handling binary data.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom


require 'imw/utils'
require 'imw/model/files/basicfile'

module IMW
  module Files

    class Binary
      
      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path
        set_path path
      end

    end
    
  end
end
