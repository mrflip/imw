
# h2. lib/imw/files/json.rb -- describes json files
#
# == About
#
# A class for working with JSON files.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Yet another clever comment." # at bottobm

require 'json'
require 'imw/utils'
require 'imw/files/text'

module IMW
  module Files

    class Json < IMW::Files::Text

      def initialize path, mode='r', options = {}
        super path, mode
      end

      # Return the contents of this JSON file.
      #
      # FIXME what to do if a block is passed in?
      def load &block
        JSON.parse File.new(@path).read
      end

      # Dump +data+ to this file as JSON.
      def dump data
        super data.to_json
      end
    end
    FILE_REGEXPS << [/\.json$/, IMW::Files::Json]
  end
end
