require 'spreadsheet'

# FIXME Main issue with this:
# You can make a new excel book and dump data to it no problem.
# However, something that doesn't seem to work is dumping to a file, opening,
# and dumping to it again. At the moment this is probably not a big deal.
module IMW
  module Files
    #Simple wrapper for the Spreadsheet library. Enables
    #IMW to load and dump to Excel files.
    #
    #Example:
    #
    #        data = [[1,2,3],[4,5,6]]
    #        IMW.open( 'dumpd.xls' ).dump(data)
    #
    class Excel
      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      attr_accessor :book,:idx, :max_lines, :sht_idx, :sht_row, :book_idx
      #If an Excel file exists at the location specified by uri then
      #it is opened and can be read out with a subsequent call to
      #load(). Otherwise, a new workbook is created and can be written
      #to with the dump() method.
      def initialize uri, mode='r', options={}
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

      #Returns the data in an existing workbook as an
      #array of arrays. Only capable of reading a single sheet.
      def load
        @sheet.map{|row| row.to_a}
      end

      #Dumps data, which is assumed to be an array of arrays, to a
      #newly created Excel workbook. Attempting to dump to a book
      #that already exists will typically result in file corruption.
      #Raises a 'too many lines' error if the number of lines
      #of data exceeds max_lines.
      def dump data
        data.each do |line|
          raise "too many lines" if too_many?
          self << line
        end
        save unless no_data?
      end

      #Processes a single line of data and updates internal variables.
      #You shouldn't need to call this directly.
      def << line
        @sheet.row(@sht_row).concat( line )
        @sht_row += 1
        @idx += 1
      end

      #Instantiates a new Excel workbook in memory. You shouldn't
      #need to call this directly.
      def make_new_book
        @book = Spreadsheet::Workbook.new
        @book_idx += 1
      end

      #Makes a new worksheet for a pre-existing Excel workbook.
      #This should be called after recovering from the
      #'too many lines' error.
      def make_new_sheet
        @sheet = @book.create_worksheet
        @sht_idx += 1
        @sht_row = 0 #always start at row 0 in a new sheet
      end

      #Opens an existing Excel workbook. You shoudn't need to
      #call this directly.
      def get_existing_book
        @book = Spreadsheet.open path
        @sheet = book.worksheet 0
        @sht_row = @sheet.row_count #would like to be able to dump new data, doesn't work
        @sht_idx += 1
      end

      #Increments the current sheet to the next one in
      #an open book. Not necessary at the moment.
      def incr_sheet
        @sheet = book.worksheet @sht_idx
      end

      #There are too many lines if the number of rows attempting
      #to be written exceeds max_lines.
      def too_many?
        @sht_row >= @max_lines
      end

      #There is no data if the number of rows attempting to be written
      #is zero.
      def no_data?
        @sht_row == 0
      end

      #Saves the workbook.
      def save
        @book.write path
      end
    end
  end
end
