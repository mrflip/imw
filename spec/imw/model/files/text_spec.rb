#
# h2. spec/imw/model/files/text_spec.rb -- spec for text files
#
# == About
#
# RSpec testing of <tt>IMW::Files::Text</tt> class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'

require 'imw/model/files/text'
require 'imw/utils/random'

require 'rubygems'
require 'spec'

require 'imw/model/files/compressible_spec'

describe IMW::Files::Text do

  def create_file
    IMW::Random.file @file.path
  end
  
  before(:each) do
    @root_directory = IMW::DIRECTORIES[:tmp] + "/text_spec"
    FileUtils.mkdir @root_directory

    @path = @root_directory + "/file.txt"
    @copy_of_original_path = @root_directory + "/file_copy.txt"

    @file = IMW::Files::Text.new(@path)
  end

  after(:each) do
    FileUtils.rm_rf @root_directory
  end
  
  include IMW_FILES_COMPRESSIBLE_GZIP_SHARED_SPEC
  include IMW_FILES_COMPRESSIBLE_BZIP2_SHARED_SPEC
end

# puts "#{File.basename(__FILE__)}: You'll never learn to read if you don't try." # at bottom
