#
# h2. lib/imw/utils/components.rb -- define separate components of IMW
#
# == About
#
# Defines a hash <tt>IMW::COMPONENTS</tt> which keys component names
# to the files to be required to implement each component and defines
# methods to load these files.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/utils/error'

module IMW

  # Defines IMW components and the files required by each.  Components
  # can be accessed using <tt>IMW.load_components</tt> or
  # <tt>IMW#imw_components</tt>.
  COMPONENTS = {
    :datamapper => ["imw/dataset/datamapper","imw/dataset/datamapper/time_and_user_stamps"],
    :data_mapper => :datamapper,
    :html_parser => "imw/parsers/html_parser",
    :flat_file_parser => "imw/parsers/flat_file_parser",
    :line_parser => "imw/parsers/line_parser",
    :infochimps => ["imw/infochimps/infochimps_resource","imw/infochimps/icss"]
  }

  # Load components of IMW as needed,
  #
  #   IMW.load_components :datamapper, :flat_file_parser
  def self.load_components *args
    args.each do |component_name|
      begin
        require component_name.to_s
      rescue LoadError
        component = IMW::COMPONENTS[component_name]
        raise IMW::Error.new("#{component_name} is an invalid IMW component.  See IMW::COMPONENTS.") unless component        
        if component.is_a? Array then
          IMW.load_components *component
        else
          IMW.load_components component
        end
      end
    end
  end

  # Load components of IMW as needed,
  #
  #   include IMW
  #   imw_components :datamapper, :flat_file_parser
  def imw_components *args
    IMW.load_components *args
  end

end

