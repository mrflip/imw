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

require 'imw/utils'
require 'imw/model/files/text'

module IMW
  module Files

    class Yaml < IMW::Files::Text

      attr_reader :contents

      def initialize path, mode='r', options = {}
        super path, mode
        unless mode == 'w' then
          @contents = YAML.load_file @path
        end
      end

      # FIXME should a `<<' method be implemented which forces
      # non-literal content to be converted to yaml before being
      # written to file?

    end

    FILE_REGEXPS[Regexp.new("\.yaml$")] = IMW::Files::Yaml
    FILE_REGEXPS[Regexp.new("\.yml$")]  = IMW::Files::Yaml    
    
  end
end

# puts "#{File.basename(__FILE__)}: Yet another clever comment." # at bottobm
