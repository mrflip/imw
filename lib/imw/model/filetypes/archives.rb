#
# h2. lib/imw/model/archive.rb -- classes for manipulating various archive formats
#
# == About
#
# These classes subclass the IMW::Filetype class to describe and ease
# operations with particular file formats.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/filetype'



module IMW

  module Archive

    class Tar < IMW::Filetype

      attr_reader :extensions

    end

  end

end


# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
