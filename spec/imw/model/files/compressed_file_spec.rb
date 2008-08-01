#
# h2. spec/imw/model/files/compressed_file_spec.rb -- shared specs for compressed files
#
# == About
#
# Defines a shared spec +IMW_FILES_COMPRESSEDFILE_SHARED_SPEC+ for
# inclusion in specs for classes which subclass
# <tt>IMW::Files::CompressedFile</tt>.
#
# An including spec must define the following instance variables:
#
# <tt>@root_directory</tt>:: directory inside which all files will be
# created
#
# <tt>@file</tt>:: the file to be decompressed
#
# <tt>@copy_of_original_path</tt>:: path where a copy of
# <tt>@file</tt> can be put during testing
#
# An including spec can also optionally redefine the
# +create_compressed_file+ method to create the proper file during
# each example.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/matchers/file_contents_matcher'

require 'imw/utils/random'
require 'imw/model/files/text'
share_as :IMW_FILES_COMPRESSEDFILE_SHARED_SPEC do

  include Spec::Matchers::IMW

  def create_compressed_file
    text_file_path = @root_directory + "/sample.txt"
    IMW::Random.file text_file_path
    text_file = IMW::Files::Text.new(text_file_path)
    compressed_text_file = text_file.compress! @file.compression[:program]
    compressed_text_file.mv @file.path
  end

  describe "when decompressing" do

    before(:each) do
      FileUtils.mkdir_p @root_directory
    end

    after(:each) do
      FileUtils.rm_rf @root_directory
    end

    describe "and discarding original file" do

      it "should raise an error if the compressed file doesn't exist" do
        lambda {@file.decompress! }.should raise_error(IMW::PathError)
      end

      it "should decompress a compressed file which exists" do
        create_compressed_file
        decompressed_file = @file.decompress!
        decompressed_file.exist?.should eql(true)
      end

      it "should not exist after decompression" do
        create_compressed_file
        decompressed_file = @file.decompress!
        @file.exist?.should eql(false)
      end
    end

    describe "and keeping original file" do

      it "should raise an error if the compressed file doesn't exist" do
        lambda {@file.decompress }.should raise_error(IMW::PathError)
      end

      it "should decompress a compressed file which exists" do
        create_compressed_file
        decompressed_file = @file.decompress
        decompressed_file.exist?.should eql(true)
      end

      it "should be identical to how it was before decompression" do
        create_compressed_file
        @file.cp @copy_of_original_path
        decompressed_file = @file.decompress
        @copy_of_original_path.should have_contents_matching_those_of(@file.path)
      end
    end
  end
end  unless defined? IMW_FILES_COMPRESSEDFILE_SHARED_SPEC

# puts "#{File.basename(__FILE__)}: You whack the cabinet with your Monkeywrench sending files and papers everywhere.  You smile." # at bottom
