#
# h2. spec/imw/model/files/file_spec.rb -- spec for a file object
#
# == About
#
# RSpec test code for <tt>IMW::Files::File</tt>.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'

require 'imw/model/files/file'
require 'imw/utils'
require 'imw/utils/random'

require 'rubygems'
require 'spec'

require 'imw/matchers/file_contents_matcher'

describe IMW::Files::File do

  include Spec::Matchers::IMW

  def create_file
    IMW::Random.file @path
  end

  before(:all) do
    @root_directory = IMW::DIRECTORIES[:dump] + "/file_spec"
    FileUtils.mkdir @root_directory
    
    @path = @root_directory + "/file.ext"
    @copy_of_original_path = @root_directory + "/file_copy.ext"
    
    @file = IMW::Files::File.new(@path)    
    
    @new_path_same_extension = @root_directory + "/file_new.ext"
    @new_path_different_extension = @root_directory + "/file_new.next"
  end
  
  after(:each) do
    FileUtils.rm Dir.glob(@root_directory + "/*")
  end

  after(:all) do
    FileUtils.rm_rf @root_directory
  end
  
  describe "(attributes)" do
    it "should have the correct path" do
      @file.path.should eql(@path)
    end

    it "should have the correct directory name" do
      @file.dirname.should eql(@root_directory)
    end

    it "should have the correct basename" do
      @file.basename.should eql("file.ext")
    end

    it "should have the correct extension" do
      @file.extname.should eql(".ext")
    end
  end

  describe "(existence)" do
    it "should not exist if there is no file matching it on disk" do
      @file.exist?.should eql(false)
    end

    it "should exist if there is a file matching it on disk" do
      create_file
      @file.exist?.should eql(true)
    end
  end

  describe "(deletion)" do
    it "should raise an error if it tries to delete itself but it doesn't exist" do
      lambda { @file.rm }.should raise_error(IMW::PathError)
    end

    it "should delete itself if it it exists on disk" do
      create_file
      @file.rm
      @file.exist?.should eql(false)
    end
  end

  describe "(copying)" do
    it "should raise an error if it tries to copy itself but it doesn't exist" do
      lambda { @file.cp @new_path_same_extension }.should raise_error(IMW::PathError)
    end

    it "should copy itself with the same extension" do
      create_file
      new_file = @file.cp @new_path_same_extension
      new_file.path.should have_contents_matching_those_of(@file.path)
    end

    it "should raise an error if it tries to copy itself with a differing extension without :force" do
      create_file
      lambda { @file.cp @new_path_different_extension }.should raise_error(IMW::Error)
    end

    it "should copy itself with a differing extension with :force" do
      create_file
      new_file = @file.cp @new_path_different_extension, :force => true
      new_file.path.should have_contents_matching_those_of(@file.path)
    end
  end

  describe "(moving)" do
    it "should raise an error if it tries to move itself but it doesn't exist" do
      lambda { @file.mv @new_path_same_extension }.should raise_error(IMW::PathError)
    end

    it "should move itself with the same extension" do
      create_file
      old_file = @file.cp @copy_of_original_path
      new_file = @file.mv @new_path_same_extension
      new_file.path.should have_contents_matching_those_of(old_file.path)
    end

    it "should raise an error if it tries to move itself with a differing extension without :force" do
      create_file
      lambda { @file.mv @new_path_different_extension }.should raise_error(IMW::Error)
    end

    it "should move itself with a differing extension with :force" do
      create_file
      old_file = @file.cp @copy_of_original_path
      new_file = @file.mv @new_path_different_extension, :force => true
      new_file.path.should have_contents_matching_those_of(old_file.path)
    end
  end
end


# puts "#{File.basename(__FILE__)}: You place the manilla file folder between the rusty teeth of your Monkeywrench and tighten..." # at bottom
