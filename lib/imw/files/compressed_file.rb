#
# h2. lib/imw/files/compressed_file.rb -- class describing compressed files
#
# == About
#
# Compression of files is handled via the
# <tt>IMW::Files::Compressible</tt> module which can be included by
# any object that has a <tt>@path</tt> attribute.  The methods defined
# there compress files and return this
# <tt>IMW::Files::CompressedFile</tt> object which has methods for
# decompression.
#
# A subclass of this class must define a +compression+ instance
# variable which is a hash with the following keys:
#
# <tt>:program</tt>:: a symbol naming the program used for
# compression/decompression which must be one of the symbols in
# <tt>IMW::EXTERNAL_PROGRAMS</tt>
#
# <tt>:decompression_flags</tt>:: a string of flags to pass to the
# compression program when decompressing the file.
#
# A subclass must also define the method +decompressed_path+ which
# returns the path of the file post-decompression.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Have you ever folded up the wrapper of a soda straw into a little accordian shape and let a drop of water soak into it?" # at bottom
module IMW
  module Files

    module BasicFile
      def compressed?
        false
      end
    end
    
    # A module which provides methods for decompressing a compressed
    # file.  An including should define an instance variable
    # <tt>@compression</tt> with two keys:
    #
    #  <tt>:program</tt>:: a symbol from <tt>IMW::EXTERNAL_PROGRAMS</tt>
    #  <tt>:decompression_flags</tt>:: a string specifying flags to pass to the decompression program
    module CompressedFile

      attr_reader :compression

      # Is this file compressed?
      def compressed?
        true
      end
      
      # Construct the command passed to the shell to decompress this
      # file.
      def decompression_command
        [IMW::EXTERNAL_PROGRAMS[@compression[:program]],@compression[:decompression_flags],@path].join ' '
      end
        
      public
      # Decompress this file in its present directory overwriting any
      # existing files and without saving the original compressed
      # file.
      def decompress!
        raise IMW::PathError.new("cannot decompress #{@path}, doesn't exist!") unless exist?
        FileUtils.cd(@dirname) { IMW.system decompression_command }
        IMW.open(decompressed_path)
      end

      # Decompress this file in its present directory, overwriting any
      # existing files while keeping the original compressed file.
      #
      # The implementation is a little stupid, as the file is
      # needlessly copied.
      def decompress
        raise IMW::PathError.new("cannot decompress #{@path}, doesn't exist!") unless exist?        
        begin
          FileUtils.cp(@path,@path + 'copy')
          decompress!
        ensure
          FileUtils.mv(@path + 'copy',@path)
        end
        IMW.open(decompressed_path)
      end

    end
  end
end



