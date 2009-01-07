#
# h2. lib/imw/model/files/sgml.rb -- SGML files
#
# == About
#
# For SGML-derived files, including XML, HTML, &c..
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

      def initialize path,mode='r',options = {}
        self.path= path
        super Hpricot.make(File.new(@path).read),options
      end

    end

    FILE_REGEXPS[Regexp.new("\.xml$")] = IMW::Files::Xml

    class Html < Hpricot::Doc

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path,mode='r',options = {}
        self.path= path
        super Hpricot.make(File.new(@path).read),options
      end

    end

    FILE_REGEXPS[Regexp.new("\.html$")] = IMW::Files::Html
    FILE_REGEXPS[Regexp.new("\.htm$")]  = IMW::Files::Html
  end

end



