#
# h2. lib/imw/parsers/flat_file_parser.rb -- flat file parser
#
# == About
#
# Implements a parser for flat files which takes simple "cartoon"
# descriptions of the (oftentimes weird) format of each line.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

module IMW
  
  # A FlatFileParser is a line-oriented parser which uses either a
  # cartoon or a regular expression to extract data from a line.  A
  # file containing lines matching the format
  # 
  #   151.199.53.145 - - [14/Oct/2007:13:34:34 -0500] "GET /phpmyadmin/main.php HTTP/1.0" 200 14219 "-" "-"
  #   81.227.179.120 - - [14/Oct/2007:13:34:34 -0500] "GET /phpmyadmin/libraries/select_lang.lib.php HTTP/1.0" 200 352 "-" "-"
  #   81.3.107.173  - - [14/Oct/2007:13:54:26 -0500] "GET / HTTP/1.1" 200 857 "-" "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/419.2 (KHTML, like Gecko) Safari/419.3"
  #
  # Could be parsed using a regular expression, turning each line into
  # a Hash of field names with values:
  # 
  #   file   = File.new '/path/to/file.log'
  #   parser = FlatFileParser.new :by_regexp   => /^([0-9.]+).*\[([0-9]{2}\/[A-Za-z]{3}\/[0-9]{4}:[0-9]{2}:[0-9]{2} -[0-9]{4})\] "GET ([^ ]+).*$/,
  #                               :into_fields => [:ip,:date,:url]
  #   parser.parse file #=> [{:ip => '151.199.53.145', :date => '14/Oct/2007:13:34:34 -0500', :url => '/phpmyadmin/main.php'}, ... ]
  #
  # If the parser is instantiated with the <tt>:of</tt> keyword then
  # use the hash from each line to instantiate a new object of the
  # corresponding class (as long as it obeys hash semantics).
  #
  #   class Hit < Struct.new(:ip, :date, :url)
  #   end
  #   
  #   parser = FlatFileParser.new :by_regexp   => /^([0-9.]+).*\[([0-9]{2}\/[A-Za-z]{3}\/[0-9]{4}:[0-9]{2}:[0-9]{2} -[0-9]{4})\] "GET ([^ ]+).*$/,
  #                               :into_fields => [:ip,:date,:url],
  #                               :of          => Hit
  #   parser.parse file #=> [#<struct Foo ip="151.199.53.145", date="14/Oct/2007:13:34:34 -0500", url="/phpmyadmin/main.php">, ... ]
  #
  # Instead of a regular expression, a FlatFileParser can also be
  # instantiated with a "cartoon".  A cartoon captures the structure
  # of each line of the file.
  #
  # FIXME how the hell do these cartoons work anyway?
  class FlatFileParser
    attr_accessor :cartoon, :regexp, :klass, :last_line

    # A FlatFileParse is declared with either a <tt>:by_regexp</tt>
    # or <tt>:by_cartoon</tt> keyword argument (if both are given,
    # <tt>:by_regexp</tt> is used).
    #
    # If the <tt>:skip_first</tt> keyword option is given then skip
    # that many lines at the top of each file parsed.
    def initialize options
      @regexp     = options[:regexp]     || options[:by_regexp]
      @cartoon    = options[:cartoon]    || options[:by_cartoon]
      @fields     = options[:fields]     || options[:into_fields]
      @klass      = options[:of]
      @skip_first = options[:skip_first] || 0
      @last_line  = nil
      regexp_from_cartoon if @cartoon && !@regexp
      raise IMW::Error.new("A FlatFileParser must be initialized with either the :with_regexp or :with_cartoon keyword arguments.") unless @regexp
      raise IMW::Error.new("A FlatFileParser must be initialized with an array of :fields.") unless @fields.respond_to? :each
    end

    # Parse +file+ line-by-line.  If a block is passed in and this
    # parser was instantiated without the <tt>:of</tt> keyword, then
    # pass the hash created from parsing each line according to either
    # <tt>:by_regexp</tt> or <tt>:by_cartoon</tt>
    # <tt>:into_fields</tt> to the block.  If the <tt>:of</tt> keyword
    # was used then instead pass an object of the class named by
    # <tt>:of</tt> instantiated from the hash for the line.
    #
    # If no block is given, just return an Array of all the parsed
    # lines.
    #
    # If the keyword <tt>:lines</tt> is given then only parse the
    # given number of lines.
    def parse file, options = {}, &block
      options.reverse_merge!({:lines => (1.0/0)})
      skip_lines file, @skip_first
      line_num = 1
      max_line = options[:lines]
      case
      when block && @klass
        file.each do |line|
          break if line_num > max_line
          yield @klass.new(hash_from_line(line))
          line_num += 1
        end
      when block && !@klass
        file.each do |line|
          break if line_num > max_line
          yield hash_from_line(line)
          line_num += 1
        end
      when @klass
        lines = []
        file.each do |line|
          break if line_num > max_line
          lines << line
          line_num += 1
        end
        lines.map {|line| @klass.new(hash_from_line(line)) }
      else
        lines = []
        file.each do |line|
          break if line_num > max_line
          lines << line
          line_num += 1
        end
        lines.map {|line| hash_from_line(line) }        
      end
    end

    private
    def hash_from_line line
      @last_line = line
      m = @regexp.match line
      return {} unless m
      Hash.zip @fields, m.captures
    end

    def skip_lines file, n_lines
      return unless file
      n_lines.times do file.gets end
    end

    def regexp_from_cartoon
      template = cartoon.gsub(/\A\s+/,'').split(/\n/).first
      template.gsub!(/s(\d+)/, '(.{\1,\1})')
      template.gsub!(/c/,      '(.)')
      template.gsub!(/i(\d+)/, '(.{\1,\1})')
      template.gsub!(/\s/, '')
      @regexp = %r{^#{template}$}
    end
  end
end
