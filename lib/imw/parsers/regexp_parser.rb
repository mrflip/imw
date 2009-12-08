require 'imw/parsers/line_parser'

module IMW
  module Parsers
    
    # A RegexpParser is a line-oriented parser which uses a regular
    # expression to extract data from a line into either a hash or an
    # object obeying hash semantics.
    #
    # As an example, a flat file with one record per line in the
    # following format (this is a simplified version of common
    # webserver log formats)
    #
    #   151.199.53.145 14-Oct-2007:13:34:34-0500 GET /phpmyadmin/main.php HTTP/1.0
    #   81.227.179.120 14-Oct-2007:13:34:34-0500 GET /phpmyadmin/libraries/select_lang.lib.php HTTP/1.0
    #   81.3.107.173 14-Oct-2007:13:54:26-0500 GET / HTTP/1.1
    #   ...
    #
    # could be parsed as follows
    # 
    #   file   = File.new '/path/to/file.log'
    #   parser = IMW::Parsers::RegexpParser.new :by_regexp   => %r{^([\d\.]+) (\d{2}-\w{3}-\d{4}:\d{2}:\d{2}:\d{2}-\d{4}) (\w+) ([^\s]+) HTTP/([\d.]{3})$},
    #                                           :into_fields => [:ip, :timestamp, :verb, :url, :version]
    #   parser.parse file #=> [{:ip => '151.199.53.145', :timestamp => '14-Oct-2007:13:34:34-0500', :verb => 'GET', :url => '/phpmyadmin/main.php', :version => "1.0"}, ... ]
    #
    # Consecutive captures from the regular expression will be pushed
    # into a hash with keys given by the +into_fields+ property of
    # this parser.
    #
    # If the parser is instantiated with the <tt>:of</tt> keyword then
    # the parsed hash from each line is used to instantiate a new
    # object of the corresponding class:
    #
    #   require 'ostruct'
    #   
    #   PageView = Class.new(OpenStruct)
    #   
    #   parser = IMW::Parsers::RegexpParser.new :by_regexp   => %r{^([\d\.]+) (\d{2}-\w{3}-\d{4}:\d{2}:\d{2}:\d{2}-\d{4}) (\w+) ([^\s]+) HTTP/([\d.]{3})$},
    #                                           :into_fields => [:ip, :timestamp, :verb, :url, :version],
    #                                           :of          => PageView
    #                                           
    #   parser.parse! file #=> [#<PageView ip="151.199.53.145", timestamp="14-Oct-2007:13:34:34-0500", verb="GET", url="/phpmyadmin/main.php", version="1.0">, ... ]
    class RegexpParser < LineParser
      attr_accessor :regexp, :fields

      def initialize options={}
        @regexp = options[:regexp] || options[:by_regexp]
        @fields = options[:fields] || options[:into_fields]
        super options
      end

      def parse_line line
        match_data = regexp.match(line)
        returning({}) do |hsh|
          if match_data
            match_data.captures.each_with_index do |capture, index|
              hsh[fields[index]] = capture
            end
          end
        end
      end
    end
  end
end

