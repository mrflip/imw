#
# h2. lib/imw/files/yaml.rb -- describes yaml files
#
# == About
#
# A class for working with YAML files.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'yaml'

require 'imw/utils'
require 'imw/files/text'

module IMW
  module Files

    class Yaml < IMW::Files::Text

      def initialize path, mode='r', options = {}
        super path, mode
      end

      # Return the contents of this YAML file.
      #
      # FIXME what to do if a block is passed in?
      def load &block
        YAML.load_file @path
      end

      # Dump +data+ to this file as YAML.
      def dump data
        super data.to_yaml
      end
      
    end

    FILE_REGEXPS << [/\.yaml$/, IMW::Files::Yaml]
    FILE_REGEXPS << [/\.yml$/,  IMW::Files::Yaml]
    
  end
end

# puts "#{File.basename(__FILE__)}: Yet another clever comment." # at bottobm
