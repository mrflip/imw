#
# h2. lib/imw/model/files/tar.rb -- describes a tar file
#
# == About
#
# Class for describing a tar archive.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/basicfile'
require 'imw/model/files/archive'
require 'imw/model/files/compressible'

require 'imw/utils'

module IMW

  module Files

    class Tar < IMW::Files::BasicFile

      # The default flags used creating, appending to, listing, and
      # extracting a tar archive.
      DEFAULT_FLAGS = {
        :create => "-cf",
        :append => "-rf",
        :list => "-tf",
        :extract => "-xf"
      }

      include IMW::Files::Archive
      include IMW::Files::Compressible

      def initialize path
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a tar archive.") unless @extname == '.tar'
        @archive = {
          :program => :tar,
          :create_flags => DEFAULT_FLAGS[:create],
          :append_flags => DEFAULT_FLAGS[:append],
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract]
        }

      end
    end
  end
end

# puts "#{File.basename(__FILE__)}: Even ancient mammoths have been preserved by tar!" # at bottom

