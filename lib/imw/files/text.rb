#
# h2. lib/imw/files/text.rb -- describes text files
#
# == About
#
module IMW
  module Files
    
    # Used to process text files when no more specialized class is suitable.
    #
    #   f = IMW::Files::Text.new '/path/to/my_file.dat'
    #   f.load do |line|
    #     # ...
    #   end
    #
    # Missing methods will be passed to the associated file handle
    # (either IO or StringIO depending on whether the URI passed in
    # was local or remote) so the usual stuff like read or each_line
    # still works.
    class Text

      include IMW::Files::BasicFile
      include IMW::Files::Compressible

      attr_reader :file

      def initialize uri, mode='r', options = {}
        self.uri= uri
        raise IMW::PathError.new("Cannot write to remote file #{uri}") if mode == 'w' && remote?
        @file = open(uri, mode)
      end

      # Return the contents of this text file as a string.  If given a
      # block, then pass each line of the string to the block.
      def load &block
        if block
          file.each_line {|line| yield line}
        else
          file.read
        end
      end

      # Dump +data+ to this file as a string.  Close the file handle
      # if passed in :close.
      def dump data, options={}
        @file.write(data.inspect)
        @file.close if options[:close]
      end

      def method_missing method, *args
        @file.send method, *args
      end
      
    end
  end
end

# puts "#{File.basename(__FILE__)}: Don't forget to put a nametag on your Monkeywrench or one of the other chimps might steal it!" # at bottom
