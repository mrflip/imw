require 'uri'
require 'open-uri'
require 'imw/utils'
require 'imw/files/basicfile'
require 'imw/files/directory'
require 'imw/files/archive'
require 'imw/files/compressible'
require 'imw/files/compressed_file'

module IMW

  # Parse +path+ and return an appropriate handler.  Pass in <tt>:write
  # => true</tt> to open for writing.
  #
  #   IMW.open("/tmp/test.csv") # => IMW::Files::Csv("/tmp/test.csv')
  #
  #
  def self.open path, options = {}, &block
    if File.directory?(File.expand_path(path))
      dir = Files::Directory.new(path)
      yield dir if block_given?
      dir
    else
      mode = options[:write] ? 'w' : 'r'
      file = Files.file_class_for(path, options).new(path, mode, options)
      yield file if block_given?
      file
    end
  end

  def self.open! path, options = {}, &block
    self.open path, options.reverse_merge(:write => true)
  end

  module Files


    # There is certainly a cleaner way to do this.
    autoload :Text,   'imw/files/text'
    autoload :Binary, 'imw/files/binary'
    autoload :Yaml,   'imw/files/yaml'
    autoload :Csv,    'imw/files/csv'
    autoload :Tsv,    'imw/files/csv'
    autoload :Json,   'imw/files/json'
    autoload :Bz2,    'imw/files/compressed_files_and_archives'
    autoload :Gz,     'imw/files/compressed_files_and_archives'
    autoload :Tar,    'imw/files/compressed_files_and_archives'
    autoload :Tarbz2, 'imw/files/compressed_files_and_archives'
    autoload :Targz,  'imw/files/compressed_files_and_archives'
    autoload :Rar,    'imw/files/compressed_files_and_archives'
    autoload :Zip,    'imw/files/compressed_files_and_archives'
    autoload :Xml,    'imw/files/sgml'
    autoload :Html,   'imw/files/sgml'
    autoload :Excel,  'imw/files/excel'


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
                          [/\.txt$/,      :text],
                          [/\.txt$/,      :text],
                          [/\.dat$/,      :text],
                          [/\.ascii$/,    :text],
                          [/\.yaml$/,     :yaml],
                          [/\.yml$/,      :yaml],
                          [/\.csv$/,      :csv],
                          [/\.tsv$/,      :tsv],
                          [/\.json$/,     :json],
                          [/\.bz2$/,      :bz2],
                          [/\.gz$/,       :gz],
                          [/\.tar\.bz2$/, :tarbz2],
                          [/\.tbz2$/,     :tarbz2],
                          [/\.tar\.gz$/,  :targz],
                          [/\.tgz$/,      :targz],
                          [/\.tar$/,      :tar],
                          [/\.rar$/,      :rar],
                          [/\.zip$/,      :zip],
                          [/\.xml$/,      :xml],
                          [/\.html$/,     :html],
                          [/\.htm$/,      :html],
                          [/\.xlsx?$/,    :excel]
                         ]

    SCHEME_HANDLERS = [
                       [/http/, :html]
                       ]

    protected
    def self.file_class_for path, options = {}
      klass = options.delete(:as)

      # try to choose klass from path extension if not already set
      unless klass
        EXTENSION_HANDLERS.reverse_each do |regexp, thing| # end has greater precedence
          next unless regexp =~ path
          klass = thing
          break
        end
      end

      # try to choose klass from uri scheme if not already set
      unless klass
        scheme = URI.parse(path).scheme
        SCHEME_HANDLERS.reverse_each do |regexp, thing| # end has greater precedence
          next unless regexp =~ scheme
          klass = thing
          break
        end
      end

      # just stick with text if still not set
      klass = :text unless klass

      klass.is_a?(Class) ? klass : class_eval(klass.to_s.downcase.capitalize)
    end
  end
end
