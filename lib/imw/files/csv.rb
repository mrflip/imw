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
        
      def initialize path, mode='r', options = {}
        self.path= path
        options.reverse_merge!(self.class::DEFAULT_OPTIONS)
        super File.new(@path,mode),options
      end

      # Return the contents of this CSV file as an array of arrays.
      # If given a block, then yield each row of the outer array to
      # the block.
      def load &block
        if block
          each_line {|line| yield line}
        else
          entries
        end
      end

      # Dump +data+ to this file.  Will close the I/O stream for this
      # file.
      #
      # FIXME should we have an option here to not close the I/O
      # stream but leave it open for further dumping until someone
      # calls +close+?
      def dump data
        data.each {|row| self << row}
        self.close
      end
    end

    # Represents a file of comma-separated values (CSV).  This class
    # is a subclass of <tt>FasterCSV</tt> so the methods of that
    # library are available for use.
    class Csv < TabularDataFile
    end

    # Represents a file of tab-separated values (TSV).  This class
    # is a subclass of <tt>FasterCSV</tt> so the methods of that
    # library are available for use.
    class Tsv < TabularDataFile

      # Default options to be passed to
      # FasterCSV[http://fastercsv.rubyforge.org/]; see its
      # documentation for more information.
      DEFAULT_OPTIONS[:col_sep] = "\t"
    end

    FILE_REGEXPS[Regexp.new("\.csv$")] = IMW::Files::Csv
    FILE_REGEXPS[Regexp.new("\.tsv$")] = IMW::Files::Tsv

  end
end
