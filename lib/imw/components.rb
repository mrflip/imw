#
# h2. lib/imw/components -- define separate components of IMW
#
# == About
#
# Defines a hash <tt>IMW::COMPONENTS</tt> which keys component names
# to the files to be required to implement each component.  This hash
# can be accessed via <tt>IMW.load_components</tt>
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

module IMW
  
  COMPONENTS = {
    :datamapper => "imw/dataset",
    :html_parser => "imw/parsers/html_parser",
    :flat_file_parser => "imw/parsers/flat_file_parser"
  }

  # Load components of IMW as needed,
  #
  #   IMW.load_components :datamapper, :flat_file_parser
  def self.load_components *args
    args.each do |component_name|
      thing_to_require = IMW::COMPONENTS[component_name]
      if thing_to_require.is_a? String then
        require thing_to_require
      elsif thing_to_require.is_a? Array then
        IMW.load_components *thing_to_require
      elsif thing_to_require.is_a? Symbol then
        IMW.load_components thing_to_require
      else
        raise IMW::Error.new("#{component_name} is an invalid IMW component.  See IMW::COMPONENTS.")
      end
    end
  end

  # Load components of IMW as needed,
  #
  #   imw_components :datamapper, :flat_file_parser
  def imw_components *args
    IMW.load_components *args
  end

end

