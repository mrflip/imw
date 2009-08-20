#
# h2. lib/imw/files.rb -- uniform interface to various files
#
# == About
#
# Implements <tt>IMW.open</tt> which returns an appropriate +IMW+
# object given a URI.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'uri'

require 'imw/utils'
require 'imw/files/text'
require 'imw/files/binary'
require 'imw/files/data_formats'
require 'imw/files/compressed_files_and_archives'

module IMW

  # Parse +path+ and return an appropriate handler.  Pass in <tt>:write
  # => true</tt> to open for writing.
  #
  #   IMW.open("/tmp/test.csv") # => IMW::Files::Csv("/tmp/test.csv')
  #
  # 
  def self.open path, options = {}
    mode = options[:write] ? 'w' : 'r'
    klass = Files.file_class_for(path)
    Files.file_class_for(path).new(path, mode, options)
  end

  def self.open! path, options = {}
    self.open path, options.reverse_merge(:write => true)
  end

  module Files

    # An array used to match files to classes to handle them.  The
    # first element of each array is the regexp and the second names
    # the class to handle the file.
    #
    #  IMW::Files::EXTENSION_HANDLERS << [ /\.csv$/, :csv ] #=> IMW::Files::Csv
    #  IMW::Files::EXTENSION_HANDLERS << [ /\.txt$/, "Text" ] #=> IMW::Files::Text
    #  IMW::Files::EXTENSION_HANDLERS << [ /\.myclass%/, MyClass ] #=> MyClass
    #
    # Elements at the end of the array have greater precedence which
    # allows, say, <tt>.tar.gz</tt> to be handled differently from
    # <tt>.gz</tt>.
    EXTENSION_HANDLERS = [
                          [/./,           :text], # catchall
                          [/\.txt$/,      :text],                          
                          [/\.txt$/,      :text],
                          [/\.dat$/,      :text],
                          [/\.ascii$/,    :text],
                          [/\.yaml$/,     :yaml],
                          [/\.yml$/,      :yaml],
                          [/\.csv$/,      :csv],
                          [/\.tsv$/,      :tsv],
                          [/\.json$/,     :json],
                          [/\.tar\.bz2$/, :TarBz2],
                          [/\.tbz2$/,     :TarBz2],
                          [/\.tar\.gz$/,  :TarGz],
                          [/\.tgz$/,      :TarGz],
                          [/\.tar$/,      :tar],
                          [/\.bz2$/,      :bz2],
                          [/\.gz$/,       :gz],
                          [/\.rar$/,      :rar],
                          [/\.zip$/,      :zip],
                          [/\.xml$/,      :xml],
                          [/\.html$/,     :html],
                          [/\.htm$/,      :html]
                         ]
    protected
    def self.file_class_for path, options = {}
      klass = options.delete(:as)
      unless klass
        EXTENSION_HANDLERS.reverse_each do |regexp, thing| # end has greater precedence
          next unless regexp =~ path
          klass = thing
          break
        end
      end
      klass.is_a?(Class) ? klass : class_eval(klass.to_s.downcase.capitalize)
    end
  end
end
