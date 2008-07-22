#
# h2. lib/imw/model/files/compressed_file.rb -- class describing compressed files
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
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

requrie 'imw/model/files/file'

require 'imw/utils'

module IMW

  module Files

    module CompressedFile < IMW::Files::File

      attr_reader :program
      
      def initialize path
        super

        # figure out compression program
        extensions = {
          /\.bz2$/ => :bzip2,
          /\.gz$/ => :gzip
        }
        @program = extensions.find {|regex,program| program if regex.match(@path)}
      end

      private
      # Construct the command passed to the shell to decompress this
      # file.
      #
      # Options:
      # <tt>:verbose</tt> (false):: print output
      def decompression_command opts = {}
        opts.reverse_merge!({:verbose => false})

        # bzip2 and gzip share many options so no need to distinguish
        # between them when constructing this command.
        flags = opts[:verbose] ? "-fvd" : "-fd" # `f' to force overwriting

        IMW::EXTERNAL_PROGRAMS[@program] + ' ' + flags + @path
      end

      public
      # Decompress this file in its present directory overwriting any
      # existing files and without saving the original compressed
      # file.
      #
      # Options:
      # <tt>:verbose</tt> (false):: print output
      def decompress! opts = {}
        IMW.system(self.decompression_command(opts))
      end

      # Decompress this file in its present directory, overwriting any
      # existing files while keeping the original compressed file.
      #
      # Options:
      # <tt>:verbose</tt> (false):: print output
      def decompress opts = {}
        FileUtils.cp(@path,@path + 'copy')
        IMW.system(self.decompression_command(opts))
        FileUtils.mv(@path + 'copy',@path)
      end

    end
  end
end


# puts "#{File.basename(__FILE__)}: Have you ever folded up the wrapper of a soda straw into a little accordian shape and let a drop of water soak into it?" # at bottom
