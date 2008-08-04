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
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/model/files/archive_spec'

unless IMW::SpecConfig::SKIP_ARCHIVE_FORMATS.include? :rar
  require 'imw/model/files/rar'
  describe IMW::Files::Rar do

    before(:all) do
      @root_directory = ::IMW::DIRECTORIES[:dump] + "/archive_test"
      @initial_directory = @root_directory + "/create_and_append/initial"
      @appending_directory = @root_directory + "/create_and_append/appending"
      @extraction_directory = ::IMW::DIRECTORIES[:dump] + "/extract"
      @archive = IMW::Files::Rar.new(@root_directory + "/test.rar")
    end

    it_should_behave_like "an archive of files"

  end
end

# puts "#{File.basename(__FILE__)}: You bang your Monkeywrench uselessly on the locked file cabinet." # at bottom
