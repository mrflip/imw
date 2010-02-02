require 'spreadsheet'

# FIXME Main issue with this:
# You can make a new excel book and dump data to it no problem.
# However, something that doesn't seem to work is dumping to a file, opening,
# and dumping to it again. At the moment this is probably not a big deal.


module IMW
  module Files
    class Excel
      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      #need to initialize, load, and dump
      attr_accessor :book,:idx, :max_lines, :sht_idx, :sht_row, :book_idx
      def initialize uri, mode, options={}
        self.uri = uri
        @max_lines = options[:max_lines] || 65000
        @idx = 0
        @book_idx = 0
        @sht_idx = 0
        unless self.exist?
          make_new_book
          make_new_sheet
        else
          get_existing_book
        end
      end

      def load
        @sheet.map{|row| row.to_a}
      end

      def dump data
        data.each do |line|
          raise "too many lines" if too_many?
          self << line
        end
        save unless no_data?
      end

      def << line
        @sheet.row(@sht_row).concat( line )
        @sht_row += 1
        @idx += 1
      end

      def make_new_book
        @book = Spreadsheet::Workbook.new
        @book_idx += 1
      end

      def make_new_sheet
        @sheet = @book.create_worksheet
        @sht_idx += 1
        @sht_row = 0 #always start at row 0 in a new sheet
      end

      def get_existing_book
        @book = Spreadsheet.open path
        @sheet = book.worksheet 0
        @sht_row = @sheet.row_count #would like to be able to dump new data, doesn't work
        @sht_idx += 1
      end

      def incr_sheet
        @sheet = book.worksheet @sht_idx
      end

      def too_many?
        @sht_row >= @max_lines
      end

      def no_data?
        @sht_row == 0
      end

      def save
        @book.write path
      end
    end
  end
end
