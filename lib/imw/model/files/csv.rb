#
# h2. lib/imw/model/files/csv.rb -- CSV files
#
# == About
#
# For "comma-separated value" (CSV) files.
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

    class Csv < IMW::Files::Text

      def read
        FasterCSV.read(File.expand_path(@path))
      end

      def foreach
        FasterCSV.foreach(File.expand_path(@path)) do |row|
          yield row
        end
      end
      
    end
  end
end



