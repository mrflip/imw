#
# h2. lib/imw/utils/extensions/file.rb -- extensions to built-in file class
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

class File

  # Returns the name of the path given:
  # 
  #   File.name("/path/to/somefile.txt") => "somefile".
  def self.name path
    File.basename(path)[0,File.basename(path).length - File.extname(path).length]
  end
end

# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
