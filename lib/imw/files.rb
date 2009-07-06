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

  # Parse +uri+ and return an appropriate data object.  Mode can be
  # either <tt>'r'</tt> for read (default) or <tt>'w'</tt> for write.
  #
  #   IMW.open("/tmp/test.csv") # => IMW::Files::Csv("/tmp/test.csv')
  #
  # The objects returned by <tt>IMW.open</tt> present a uniform
  # interface across the different data formats they handle.
  def self.open uri, mode='r', options = {}
    uri = URI.parse(uri)
    method = {
      "file" => :open_file,
      "http" => :open_http
    }.dispatch(:open_file) {|scheme| uri.scheme == scheme}
    IMW::Files.send(method,uri,mode,options)
  end

  # Parse +uri+ and return an appropriate data object.  Mode can be
  # either <tt>'r'</tt> for read (default) or <tt>'w'</tt> for write.
  #
  #   include IMW
  #   imw_open("/tmp/test.csv") # => IMW::Files::Csv("/tmp/test.csv')
  #
  # The objects returned by <tt>imw_open</tt> present a uniform
  # interface across the different source data formats they handle.
  def imw_open uri, mode='r', options = {}
    IMW.open(uri,mode,options)
  end
  

  module Files

    protected
    # Open a file at the given +uri+.
    def self.open_file uri, mode='r', options = {}
      klass = IMW::Files::FILE_REGEXPS.dispatch(IMW::Files::Text) {|regexp| regexp.match(uri.path)}
      klass.new(uri.path,mode,options)
    end
  end
end
