#
# h2. lib/imw/model/files/rar.rb -- describes a rar archive
#
# == About
#
# Class for describing a compressed rar archive.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/model/files/file'
require 'imw/model/files/archive'

require 'imw/utils'

module IMW

  module Files

    class Rar < IMW::Files::File

      # The default flags used creating, appending to, listing, and
      # extracting a rar archive.
      DEFAULT_FLAGS = {
        :create => "a -r -o+ -inul",
        :append => "a -r -o+ -inul",
        :list => "vb",
        :extract => "x -o+ -inul"
      }

      include IMW::Files::Archive

      def initialize path
        super

        raise IMW::Error.new("#{@extname} is not a valid extension for a rar archive.") unless @extname == '.rar'
        @archive = {
          :program => :rar,
          :create_flags => DEFAULT_FLAGS[:create],
          :append_flags => DEFAULT_FLAGS[:append],
          :list_flags => DEFAULT_FLAGS[:list],
          :extract_flags => DEFAULT_FLAGS[:extract]
        }
      end
    end
  end
end

# puts "#{File.basename(__FILE__)}: Rawwwrrrrrrrrrr!" # at bottom

