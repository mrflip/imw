#
# h2. spec/imw/model/files/bz2_spec.rb -- spec for bz2 files
#
# == About
#
# RSpec code for <tt>IMW::Files::Bz2</tt>.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/model/files/compressed_file_spec'

require 'imw/model/files/bz2'
describe IMW::Files::Bz2 do

  before(:all) do
    @root_directory = IMW::DIRECTORIES[:dump] + "/bz2_spec"

    @path = @root_directory + "/file.txt.bz2"
    @file = IMW::Files::Bz2.new(@path)

    @copy_of_original_path = @root_directory + "/file_copy.txt.bz2"
  end

  it_should_behave_like "a compressed file"
end

# puts "#{File.basename(__FILE__)}: You squeeze yourself and your Monkeywrench through a narrow opening, twice." # at bottom

