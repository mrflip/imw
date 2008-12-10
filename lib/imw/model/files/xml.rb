#
# h2. lib/imw/model/files/xml.rb -- XML files
#
# == About
#
# For XML files.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/utils'
require 'imw/model/files/text'
require 'hpricot'

module IMW
  module Files

    class Xml < Hpricot::Doc

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path,options = {}
        set_path path
        super Hpricot.make(File.new(@path).read),options
      end
      
    end
  end
end



