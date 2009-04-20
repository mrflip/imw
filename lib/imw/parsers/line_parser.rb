#
# h2. lib/imw/parsers/line_parser.rb -- line parser
#
# == About
#
# Implements a relatively unsophisticated line-by-line parser for
# files.  Meant to be subclassed to create a more powerful and useful
# parser.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

module IMW

  # This is an abstract class for a line-oriented file parser.  It can
  # be used to read and emit lines sequentially from a file.
  #
  #   parser = LineOrientedFileParser.new :skip_first => 1 # skip first line when parsing
  #   file = File.new '/path/to/my/data.dat'
  #
  #   # return an array of lines transformed by the block
  #   transformed_lines = parser.parse file do |line|
  #     # ...
  #   end
  #
  # More complicated parsing is handled by classes which subclass this
  # one.
  class LineOrientedFileParser

    # The number of lines to skip on each file parsed.
    attr_accessor :skip_first


    # If called with the option <tt>:skip_first</tt> then skip the
    # corresponding number of lines at the beginning of the file when
    # parsing.
    def initialize(options)
      self.skip_first = options[:skip_first] || 0
    end

    def parse file, &block
      skip_lines file, self.skip_first
      self.respond_to?(:parse_line) ? 
      case
      when block && factory
        file.map{|line| yield self.factory.new(line) }
      when block && !factory
        file.map{|line| yield line }
      else # no block -- better be a factory
        lines.map{|line|       self.factory.new(line) }
      end
    end

  protected

    # Skip (unconditionally) a given number of lines in the file
  end
end
