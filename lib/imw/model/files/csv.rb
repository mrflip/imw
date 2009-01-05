#
# h2. lib/imw/model/files/csv.rb -- CSV, TSV files
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

require 'imw/model/files/basicfile'
require 'fastercsv'

module IMW
  module Files

    # Represents a file of comma-separated values (CSV).  This class
    # is a subclass of <tt>FasterCSV</tt> so the methods of that
    # library are available for use.
    class Csv < FasterCSV

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path, mode='r', options = {}
        self.path= path
        super File.new(@path,mode),options
      end
    end # CSV

    # Represents a file of tab-separated values (TSV).  This class
    # is a subclass of <tt>FasterCSV</tt> so the methods of that
    # library are available for use.
    class Tsv < FasterCSV

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      def initialize path, mode='r', options = {}
        self.path= path
        defaults = {:col_sep => "\t"}
        options.reverse_merge!(defaults)
        super File.new(@path,mode),options
      end
      
    end # TSV

    FILE_REGEXPS[Regexp.new("\.csv$")] = IMW::Files::Csv
    FILE_REGEXPS[Regexp.new("\.tsv$")] = IMW::Files::Tsv

  end
end
