#
# h2. lib/imw/foo -- desc lib
#
# action::    desc action     
#
# == About
#
# This file implementes <tt>IMW::Source</>> which acts as a dispatcher
# for various kinds of data sources.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils'
require 'uri'

module IMW

  # Parse +source+ and return an appropriate data object.  Mode can be
  # either <tt>'r'</tt> for read (default) or <tt>'w'</tt> for write.
  #
  #   IMW.open("/tmp/test.csv") # => IMW::Files::Csv("/tmp/test.csv')
  #
  # The objects returned by <tt>IMW.open</tt> present a uniform
  # interface across the different source data formats they handle.
  def self.open source, mode='r', options = {}
    uri = URI.parse(source)
    method = {
      "file" => :open_file,
      "http" => :open_http
    }.dispatch(:open_file) {|scheme| uri.scheme == scheme}
    IMW::Source.send(method,uri,mode,options)
  end
  
  # The <tt>IMW::Source</tt> module contains functions which wrap the
  # various kinds of data sources.
  module Source

    protected
    # Open a file at the given +uri+.
    def self.open_file uri, mode='r', options = {}
      require 'imw/model/files'
      class_name = IMW::Files::FILE_REGEXPS.dispatch("Text") {|regexp| regexp.match(uri.path)}
      # FIXME this use of 'eval' can't be the right way to do what i
      # want?
      eval("IMW::Files::#{class_name}.new(\"#{uri.path}\",mode,options)")
    end
  end
end

# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
