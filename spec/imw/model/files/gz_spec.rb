#
# h2. spec/imw/model/files/gz_spec.rb -- spec for gz files
#
# == About
#
# RSpec code for <tt>IMW::Files::Gz</tt>.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/model/files/compressed_file_spec'

require 'imw/model/files/gz'
describe IMW::Files::Gz do

  before(:all) do
    @root_directory = IMW::DIRECTORIES[:dump] + "/gz_spec"

    @path = @root_directory + "/file.txt.gz"
    @file = IMW::Files::Gz.new(@path)

    @copy_of_original_path = @root_directory + "/file_copy.txt.gz"
  end

  include IMW_FILES_COMPRESSEDFILE_SHARED_SPEC
end

# puts "#{File.basename(__FILE__)}: You squeeze yourself and your Monkeywrench through a narrow opening." # at bottom
