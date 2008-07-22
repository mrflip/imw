#
# h2. lib/imw/model/files//compressible.rb -- compression module
#
# == About
#
# Module used for compression of files.  An including
# <tt>IMW::Files::File</tt> object gains +compress+ and
# <tt>compress!</tt> methods.
#
# By default, bzip2 is used for compression though gzip can also be
# specified.  Zip and Rar compression are handled by the
# <tt>IMW::Files::Archive</tt> module.
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

require 'rubygems'
require 'activesupport'

require 'imw/utils'

module IMW

  module Files

    module Compressible

      private
      # Construct the command passed to the shell to compress this
      # file using the given +program+.
      #
      # Options:
      # <tt>:verbose</tt> (false):: print output
      def self.compression_command program, opts = {}
        opts.reverse_merge!({:verbose => false})

        raise IMW::Error.new("The only valid compression programs are bzip2 and gzip.") unless [:bzip2,:gzip].include? program

        # bzip2 and gzip share many options so no need to distinguish
        # between them when constructing this command.
        flags = opts[:verbose] ? "-fv" : "-f" # `f' to force overwriting

        IMW::EXTERNAL_PROGRAMS[program] + ' ' + flags + self.path
      end

      # Return the object representing this file comprssed with
      # +program+.
      def self.compressed_file program
        raise IMW::Error.new("The only valid compression programs are bzip2 and gzip.") unless [:bzip2,:gzip].include? program        
        case program
        when :bzip2
          ext = 'bz2'
        when :gzip
          ext = 'gz'
        end
        IMW::Files::CompressedFile.new(self.dirname + '/' + self.basename + '.' + ext)
      end
      
      public
      # Compress this file in its present directory using +program+,
      # overwriting any existing compressed files and without saving
      # the original file.  Returns an
      # <tt>IMW::Files::CompressedFile</tt> object corresponding to
      # the compressed file.
      #
      # Options:
      # <tt>:verbose</tt> (false):: print output
      def self.compress! program = :bzip2, opts = {}
        IMW.system(self.compression_command(program, opts))
        self.compressed_file program
      end

      # Compress this file in its present directory, overwriting any
      # existing compressed files while saving the original file.
      # Returns an <tt>IMW::Files::CompressedFile</tt> object
      # corresponding to the compressed file.
      #
      # Options:
      # <tt>:program</tt> (<tt>:bzip2</tt>):: names the compression program from the choices in <tt>IMW::EXTERNAL_PROGRAMS</tt>.
      # <tt>:verbose</tt> (false):: print output
      def self.compress opts = {}
        FileUtils.cp(self.path,self.path + 'copy')
        IMW.system(self.compression_command(program, opts))
        FileUtils.mv(self.path + 'copy',self.path)
        self.compressed_file program
      end

    end
    
  end

end
# puts "#{File.basename(__FILE__)}: Why is it that when you squeeze a lemon you get lemonade but when you squeeze a banana you just get a mess?" # at bottom
