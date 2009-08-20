#
# h2. lib/imw/files/sgml.rb -- SGML files
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

require 'hpricot'

require 'imw/utils'
require 'imw/files/basicfile'
require 'imw/files/compressible'
#require 'imw/parsers/html_parser'

module IMW
  module Files

    class Sgml < Hpricot::Doc

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize uri, mode='r', options={}
        self.uri= uri
        raise IMW::PathError.new("Cannot write to remote file #{uri}") if mode == 'w' && remote?
        super Hpricot.make(File.new(path).read),options
      end

      # Parse this file using the IMW HTMLParser.  The parser can
      # either be passed in directly or constructed from a passed hash
      # of matchers.
      def parse *args
        IMW.load_components :html_parser
        parser = args.first.is_a?(IMW::HTMLParser) ? args.first : IMW::HTMLParser.new(*args)
        parser.parse(self)
      end

    end

    class Xml < Sgml
    end
    
    class Html < Sgml
    end
  end

end



