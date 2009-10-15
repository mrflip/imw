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
require 'imw/files/text'
require 'imw/parsers/html_parser'

module IMW
  module Files

    module Sgml

      attr_accessor :doc

      def initialize uri, mode='r', options={}
        super uri, mode, options
        @doc = Hpricot(open(uri))
      end

      # Delegate to Hpricot
      def method_missing method, *args, &block
        @doc.send method, *args, &block
      end

      # Parse this file using the IMW HTMLParser.  The parser can
      # either be passed in directly or constructed from a passed hash
      # of matchers.
      def parse *args
        parser = args.first.is_a?(IMW::HTMLParser) ? args.first : IMW::HTMLParser.new(*args)
        parser.parse(self)
      end

    end

    class Xml < IMW::Files::Text
      include Sgml
      def initialize uri, mode='r', options={}
        super uri, mode, options
        @doc = Hpricot.XML(open(uri))
      end
    end
    
    class Html < IMW::Files::Text
      include Sgml
      def initialize uri, mode='r', options={}
        super uri, mode, options
        @doc = Hpricot(open(uri))
      end
    end
  end
end



