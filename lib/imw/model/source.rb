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

  # The <tt>IMW::Source</tt> module's +open+ method returns an IMW
  # object appropriate for reading a source.
  module Source

    # Parse +uri+ and return the appropriate source object.  The
    # object should implement a common set of data query, retrieval,
    # and manipulation methods.
    def self.open string
      uri = URI.parse(string)
      method = {
        "file" => :open_file,
        "http" => :open_http
      }.dispatch(:open_file) {|scheme| uri.scheme == scheme}
      self.send(method,uri)
    end
    
    # Open a file at the given +uri+.
    def self.open_file(uri)
      require 'imw/model/files'
      class_name = IMW::Files::FILE_REGEXPS.dispatch("Text") {|regexp| regexp.match(uri.path)}
      eval("IMW::Files::#{class_name}.new(\"#{uri.path}\")")
    end
  end
end

# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
