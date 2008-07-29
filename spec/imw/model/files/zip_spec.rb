#
# h2. test/imw/model/files/zip_spec.rb -- tests of zip file
# 
# == About
#
# RSpec tests for <tt>IMW::Files::Zip</tt> class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'rubygems'
require 'spec'

require 'imw/model/files/zip'
require 'imw/utils'

require 'imw/model/files/archive_spec'

describe IMW::Files::Zip do

  before(:all) do
    @root_directory = ::IMW::DIRECTORIES[:tmp] + "/archive_test"
    @initial_directory = @root_directory + "/create_and_append/initial"
    @appending_directory = @root_directory + "/create_and_append/appending"
    @extraction_directory = ::IMW::DIRECTORIES[:tmp] + "/extract"
    @archive = IMW::Files::Zip.new(@root_directory + "/test.zip")
  end
  
  include ARCHIVE_COMMON_SPEC

end

# puts "#{File.basename(__FILE__)}: No matter how many times you test the integrity of a zipper at the store before you buy something it /will/ break when you take it home.!" # at bottom
