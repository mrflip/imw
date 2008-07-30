#
# h2. lib/imw/model/files/yaml.rb -- describes yaml files
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

require 'imw/model/files/text'
require 'imw/utils'

module IMW

  module Files

    class Yaml < IMW::Files::Text

      def initialize path
        super

        raise IMW::ArgumentError.new("#{@extname} is not a valid extension for a YAML file") unless /\.yaml$|\.yml$/.match @extname
      end
      
      # Load the content from this YAML file.
      def load
        raise IMW::PathError.new("can't load YAML, file doesn't exist!") unless exist?
        YAML::load_file @path
      end
      
    end
  end
end

# puts "#{File.basename(__FILE__)}: Yet another clever comment." # at bottobm
