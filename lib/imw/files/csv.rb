#
# h2. lib/imw/files/csv.rb -- CSV, TSV files
#
# == About
#
# For "comma-separated value" (CSV) and "tab-separated value" (TSV)
# files.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'fastercsv'

require 'imw/files/basicfile'
require 'imw/files/compressible'

module IMW
  module Files

    # A base class from which to subclass various types of tabular
    # data files (CSV, TSV, &c.)
    class TabularDataFile < FasterCSV

      include IMW::Files::BasicFile
      include IMW::Files::Compressible
      
      # Default options to be passed to
      # FasterCSV[http://fastercsv.rubyforge.org/]; see its
      # documentation for more information.
      DEFAULT_OPTIONS = {
        :col_sep        => ',',
        :headers        => false,
        :return_headers => false,
        :write_headers  => true,
        :skip_blanks    => false,
        :force_quotes   => false
      }
        
      def initialize uri, mode='r', options = {}
        options.reverse_merge!(self.class::DEFAULT_OPTIONS)
        self.uri= uri
        super File.new(@path,mode),options
      end

      # Return the contents of this CSV file as an array of arrays.
      def load
        entries
      end

      # Dump +data+ to this file.
      #
      # Options include:
      # <tt>:flush</tt> (true):: flush the file buffer, writing it to disk
      # <tt>:close</tt> (true):: close the file after writing +data+
      def dump data, options = {}
        options = options.reverse_merge :close => true, :flush => true
        data.each {|row| self << row}
        self.flush if options[:flush]
        self.close if options[:close]
        self
      end
    end

    # Represents a file of comma-separated values (CSV).  This class
    # is a subclass of <tt>FasterCSV</tt> so the methods of that
    # library are available for use.
    #
    # See <tt>IMW::Files::TabularDataFile</tt> for more complete
    # documentation.
    class Csv < TabularDataFile
    end

    # Represents a file of tab-separated values (TSV).  This class
    # is a subclass of <tt>FasterCSV</tt> so the methods of that
    # library are available for use.
    #
    # See <tt>IMW::Files::TabularDataFile</tt> for more complete
    # documentation.
    class Tsv < TabularDataFile
      DEFAULT_OPTIONS = {:col_sep => "\t"}.reverse_merge DEFAULT_OPTIONS
    end

    FILE_REGEXPS << [/\.csv$/, IMW::Files::Csv]
    FILE_REGEXPS << [/\.tsv$/, IMW::Files::Tsv]

  end
end
