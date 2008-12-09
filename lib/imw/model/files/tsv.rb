#
# h2. lib/imw/model/files/tsv.rb -- TSV files
#
# == About
#
# For "tab-separated value" (TSV) files.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/model/files/text'
require 'fastercsv'

module IMW
  module Files

    class Tsv < IMW::Files::Text

      def read
        FasterCSV.read(File.expand_path(@path), :col_sep => "\t")
      end

      def foreach
        FasterCSV.foreach(File.expand_path(@path), :col_sep => "\t") do |row|
          yield row
        end
      end
      
    end
  end
end



