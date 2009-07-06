#
# h2. lib/imw/files/identify.rb -- identifies files by extension
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils'

module IMW
  module Files

    # Returns the IMW file object corresponding to the extension of
    # the given +path+ by looking up the correspondence between
    # extensions and file types in <tt>IMW::EXTENSIONS</tt>.
    #
    # If no extension is found to match, then +default+ is used.
    def self.identify path, default = "Text"
      match = IMW::Files::EXTENSIONS.find {|extension| path.ends_with? extension }
      file_type_string = match ? match.last : default
      IMW::Files.const_get(file_type_string).new(path)
    end
  end
end


# puts "#{File.basename(__FILE__)}: If you can't judge a book by its cover can you at least judge a file by its extension?  I hope so..." # at bottom
