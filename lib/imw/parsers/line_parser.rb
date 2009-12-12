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
  class LineOrientedFileParser
    attr_accessor :skip_head
    # the Struct factory each record will be mapped to
    attr_accessor :factory

    #
    #
    # +:fields+         List of symbols giving field names produced by each line.
    # +:factory+        -OR- a class to act as factory for each record
    # +:skip_head+      Initial lines to skip in file
    #
    def initialize(options)
      self.skip_head = options[:skip_head] || 0
      case
      when options.include?(:factory)
        self.factory = options[:factory]
      when options.include?(:fields)
        self.factory = Struct.new(*options[:fields].map(&:to_sym))
      else
        raise "Need either a factory (can be nil) or field names"
      end
    end

    #
    #
    def parse lines, &block
      skip_lines lines, self.skip_head
      case
      when block && factory
        lines.map{|line| yield self.factory.new(line) }
      when block && !factory
        lines.map{|line| yield line }
      else # no block -- better be a factory
        lines.map{|line|       self.factory.new(line) }
      end
    end

  protected
    #
    # Skip (unconditionally) a given number of lines in the file
    #
    def skip_lines file, n_lines
      return unless file
      n_lines.times do file.gets end
    end
  end
end
