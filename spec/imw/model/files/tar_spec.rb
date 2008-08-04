#
# h2. test/imw/model/files/tar_spec.rb -- tests of tar file
#
# == About
#
# RSpec tests for <tt>IMW::Files::Tar</tt> class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/model/files/archive_spec'

require 'imw/model/files/tar'
describe IMW::Files::Tar do

  before(:all) do
    @root_directory = ::IMW::DIRECTORIES[:dump] + "/archive_test"
    @initial_directory = @root_directory + "/create_and_append/initial"
    @appending_directory = @root_directory + "/create_and_append/appending"
    @extraction_directory = ::IMW::DIRECTORIES[:dump] + "/extract"
    @archive = IMW::Files::Tar.new(@root_directory + "/test.tar")
  end

  it_should_behave_like "an archive of files"

end

# puts "#{File.basename(__FILE__)}: The tar pits are just /wonderful/ today; really, you should go in for a dip!" # at bottom
