#
# h2. test/imw/model/files/rar_spec.rb -- tests of rar file
# 
# == About
#
# RSpec tests for <tt>IMW::Files::Rar</tt> class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'rubygems'
require 'spec'

require 'imw/model/files/rar'
require 'imw/utils'

require 'imw/model/files/archive_spec'

describe IMW::Files::Rar do

  before(:all) do
    @root_directory = ::IMW::DIRECTORIES[:tmp] + "/archive_test"
    @initial_directory = @root_directory + "/create_and_append/initial"
    @appending_directory = @root_directory + "/create_and_append/appending"
    @extraction_directory = ::IMW::DIRECTORIES[:tmp] + "/extract"
    @archive = IMW::Files::Rar.new(@root_directory + "/test.rar")
  end
  
  include IMW_FILES_ARCHIVE_SHARED_SPEC

end

# puts "#{File.basename(__FILE__)}: You bang your Monkeywrench uselessly on the locked file cabinet." # at bottom
