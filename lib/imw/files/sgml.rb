require 'hpricot'
require 'imw/files/text'
require 'imw/parsers/html_parser'

module IMW
  module Files

    module Sgml

      attr_accessor :doc

      # Delegate to Hpricot
      def method_missing method, *args, &block
        @doc.send method, *args, &block
      end

      # Parse this file using the IMW::Parsers::HtmlParser.  The
      # parser can either be passed in directly or constructed from a
      # passed hash of specs and/or matchers.
      def parse *args
        parser = args.first.is_a?(IMW::Parsers::HtmlParser) ? args.first : IMW::Parsers::HtmlParser.new(*args)
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



