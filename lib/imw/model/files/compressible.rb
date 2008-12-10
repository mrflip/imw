#
# h2. lib/imw/model/files//compressible.rb -- compression module
#
# == About
#
# Module used for compression of files.  An including
# <tt>IMW::Files::BasicFile</tt> object gains +compress+ and
# <tt>compress!</tt> methods.
#
# By default, bzip2 is used for compression though gzip can also be
# specified (the full list of known compression programs is in
# <tt>IMW::Files::Compressible::COMPRESSION_PROGS</tt>).  Zip and Rar
# compression are handled by the <tt>IMW::Files::Archive</tt> module.
#
# Decompression should be handled via the
# <tt>IMW::Files::CompressedFile</tt> class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'

require 'imw/utils'

module IMW

  module Files

    module Compressible

      # Known compression programs.
      COMPRESSION_PROGS = [:bzip2, :gzip]

      # Extensions that are appended by each compression program.
      COMPRESSION_EXTS = {
        :bzip2 => '.bz2',
        :gzip => '.gz'
      }

      # Compression flags for each program
      COMPRESSION_FLAGS = {
        :bzip2 => "-f",
        :gzip => "-f"
      }

      protected
      # Check that +program+ is a valid compression program.
      def ensure_valid_compression_program program
        raise IMW::Error.new("#{program} is not a valid compression program (#{COMPRESSION_PROGS.join(' ,')}).") unless COMPRESSION_PROGS.include? program
      end
      
      # Construct the command passed to the shell to compress this
      # file using the given +program+.
      def compression_command program
        ensure_valid_compression_program program
        [IMW::EXTERNAL_PROGRAMS[program],COMPRESSION_FLAGS[program],self.path].join ' '
      end

      # Return the object representing this file compressed with
      # +program+.
      def compressed_file_path program
        ensure_valid_compression_program program
        path = File.join(self.dirname,self.basename + COMPRESSION_EXTS[program])
      end
      
      public
      # Compress this file in its present directory using +program+,
      # overwriting any existing compressed files and without saving
      # the original file.  Returns an
      # <tt>IMW::Files::CompressedFile</tt> object corresponding to
      # the compressed file.
      # 
      # Options:
      # 
      # <tt>:program</tt> (<tt>:bzip2</tt>):: names the compression
      # program from the choices in <tt>IMW::EXTERNAL_PROGRAMS</tt>.
      def compress! program = :bzip2
        raise IMW::PathError.new("cannot compress #{@path}, doesn't exist!") unless exist?
        FileUtils.cd(@dirname) { IMW.system(self.compression_command(program)) }
        self.compressed_file_path program
      end

      # Compress this file in its present directory, overwriting any
      # existing compressed files while keeping the original file.
      # Returns an <tt>IMW::Files::CompressedFile</tt> object
      # corresponding to the compressed file.
      #
      # Options:
      # 
      # <tt>:program</tt> (<tt>:bzip2</tt>):: names the compression
      # program from the choices in <tt>IMW::EXTERNAL_PROGRAMS</tt>.
      def compress program = :bzip2
        raise IMW::PathError.new("cannot compress #{@path}, doesn't exist!") unless exist?        
        begin
          FileUtils.cp(self.path,self.path + 'copy')
          compress! program
        ensure
          FileUtils.mv(self.path + 'copy',self.path)
        end
        self.compressed_file_path program        
      end
      
    end
  end
end
# puts "#{File.basename(__FILE__)}: Why is it that when you squeeze a lemon you get lemonade but when you squeeze a banana you just get a mess?" # at bottom
