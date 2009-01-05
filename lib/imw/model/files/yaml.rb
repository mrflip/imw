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

require 'imw/utils'
require 'yaml'
require 'imw/model/files/text'

module IMW

  module Files

    class Yaml < IMW::Files::Text

      # Load the content from this YAML file.
      def read
        YAML::load_file @path
      end
      
    end

    FILE_REGEXPS[Regexp.new("\.yaml$")] = IMW::Files::Yaml
    FILE_REGEXPS[Regexp.new("\.yml$")]  = IMW::Files::Yaml    
    
  end
end

# puts "#{File.basename(__FILE__)}: Yet another clever comment." # at bottobm
