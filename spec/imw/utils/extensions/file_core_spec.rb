#
# h2. spec/imw/utils/extensions/file_core_spec.rb -- spec for extensions to core file module
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require File.join(File.dirname(__FILE__),'../../../spec_helper')

require 'fileutils'

require 'imw/utils/random'

describe File do

  it "should return the 'name' of a file with 'name_of_file'" do
    File.name_of_file("/path/to/some_file.txt").should eql("some_file")
  end

  describe "when finding the uniqname corresponding to a path" do

    it "should correctly identify paths with the processing instruction suffix" do
      File.uniqname("/path/to/the_uniqname#{IMW::PROCESSING_INSTRUCTION_SUFFIX}.yaml").should eql(:the_uniqname)
    end

    it "should correctly identify paths with the metadata instruction suffix" do
      File.uniqname("/path/to/the_uniqname#{IMW::METADATA_SUFFIX}.yaml").should eql(:the_uniqname)
    end

    it "should raise an error if the path does not correspond to a uniqname" do
      lambda {File.uniqname("/path/to/the_uniqname.txt")}.should raise_error(IMW::PathError)
    end
  end

  describe "when creating unique filenames" do

    before(:each) do
      @root_directory = IMW::DIRECTORIES[:dump] + "/file_core_spec"
      @file0 = @root_directory + "/the_original.txt"
      @file1 = @root_directory + "/the_original.txt.1"
      @file2 = @root_directory + "/the_original.txt.2"
      FileUtils.mkdir(@root_directory)
    end

    after(:each) do
      FileUtils.rm_rf @root_directory
    end

    it "should return the given path if there is no such file already" do
      File.uniquify(@file0).should eql(@file0)
    end

    it "should return the given path with a numerical suffix of `.1' if the file exists" do
      IMW::Random.file(@file0)
      File.uniquify(@file0).should eql(@file1)
    end

    it "should return the given path with a numerical suffix o `.2' if the file exists and a file with a suffix of `.1' also exists" do
      IMW::Random.file(@file0)
      IMW::Random.file(@file1)
      File.uniquify(@file0).should eql(@file2)
    end

  end
  
end



# puts "#{File.basename(__FILE__)}: You bend the file folder almost in half and watch as it springs back to shape." # at bottom
