module IMW
  module Parsers

    # This is an abstract class for a line-oriented parser intended to
    # read and emit lines sequentially from a file.
    #
    # To leverage the functionality of this class, subclass it and
    # define a +parse_line+ method.
    class LineParser

      # The number of lines to skip on each file parsed.
      attr_accessor :skip_first

      # The class to parse each line into.  The +new+ method of this
      # class must accept a hash.
      attr_accessor :klass

      # If called with the option <tt>:skip_first</tt> then skip the
      # corresponding number of lines at the beginning of the file when
      # parsing.
      def initialize options={}
        @skip_first = options[:skip_first] || 0
      end

      # Parse the given file.  If the option <tt>:lines</tt> is passed
      # in then only parse that many lines.  If given a block then
      # yield the result of each line to the block; else just return
      # an array of results.
      #
      # If this parser has a +klass+ attribute then each parsed line
      # will first be turned into an instance of that class (the class
      # must accept a hash of values in its initializer).
      def parse! file, options={}, &block
        skip_lines!(file)
        if options[:lines]
          case
          when klass && block_given?
            options[:lines].times do
              yield klass.new(parse_line(file.readline))
            end
          when block_given?
            options[:lines].times do
              yield parse_line(file.readline)
            end
          when klass
            options[:lines].times do
              klass.new(parse_line(file.readline))
            end
          else
            options[:lines].times.map do
              parse_line(file.readline)
            end
          end
        else
          case
          when klass && block_given?
            file.each do |line|
              yield klass.new(parse_line(line))
            end
          when block_given?
            file.each do |line|
              yield parse_line(line)
            end
          when klass
            file.map do |line|
              klass.new(parse_line(line))
            end
          else
            file.map do |line|
              parse_line(line)
            end
          end
        end
      end

      def parse_line
        raise "Subclass the LineParser and redefine this method to create a true parser."
      end

      protected
      def skip_lines! file
        skip_first.times { file.readline }
      end
    end
  end
end
