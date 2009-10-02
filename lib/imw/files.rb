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
require 'open-uri'
require 'imw/utils'

module IMW

  # Parse +path+ and return an appropriate handler.  Pass in <tt>:write
  # => true</tt> to open for writing.
  #
  #   IMW.open("/tmp/test.csv") # => IMW::Files::Csv("/tmp/test.csv')
  #
  # 
  def self.open path, options = {}
    mode = options[:write] ? 'w' : 'r'
    Files.file_class_for(path, options).new(path, mode, options)
  end

  def self.open! path, options = {}
    self.open path, options.reverse_merge(:write => true)
  end

  module Files


    # There is certainly a cleaner way to do this.
    autoload :Text,   'imw/files/text'
    autoload :Binary, 'imw/files/binary'
    autoload :Yaml,   'imw/files/yaml'
    autoload :Csv,    'imw/files/csv'
    autoload :Json,   'imw/files/json'
    autoload :Bz2,    'imw/files/compressed_files_and_archives'
    autoload :Gz,     'imw/files/compressed_files_and_archives'
    autoload :Tar,    'imw/files/compressed_files_and_archives'
    autoload :TarBz2, 'imw/files/compressed_files_and_archives'
    autoload :TarGz,  'imw/files/compressed_files_and_archives'
    autoload :Rar,    'imw/files/compressed_files_and_archives'
    autoload :Zip,    'imw/files/compressed_files_and_archives'
    autoload :Xml,    'imw/files/sgml'
    autoload :Html,   'imw/files/sgml'
    

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
                          [/./,           :Text], # catchall
                          [/\.txt$/,      :Text],                          
                          [/\.txt$/,      :Text],
                          [/\.dat$/,      :Text],
                          [/\.ascii$/,    :Text],
                          [/\.yaml$/,     :Yaml],
                          [/\.yml$/,      :Yaml],
                          [/\.csv$/,      :Csv],
                          [/\.tsv$/,      :Tsv],
                          [/\.json$/,     :Json],
                          [/\.bz2$/,      :Bz2],
                          [/\.gz$/,       :Gz],
                          [/\.tar\.bz2$/, :TarBz2],
                          [/\.tbz2$/,     :TarBz2],
                          [/\.tar\.gz$/,  :TarGz],
                          [/\.tgz$/,      :TarGz],
                          [/\.tar$/,      :Tar],
                          [/\.rar$/,      :Rar],
                          [/\.zip$/,      :Zip],
                          [/\.xml$/,      :Xml],
                          [/\.html$/,     :Html],
                          [/\.htm$/,      :Html]
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
      klass.is_a?(Class) ? klass : class_eval(klass.to_s)
    end
  end
end
