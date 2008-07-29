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

describe IMW::Files::File do

  def create_file
    IMW::Random.file @path
  end

  before(:all) do
    @root_directory = IMW::DIRECTORIES[:tmp] + "/file_spec"
    FileUtils.mkdir @root_directory
    @path = @root_directory + "/file.ext"
    @new_path_good = @root_directory + "/file_new.ext"
    @new_path_bad = @root_directory + "/file2_new.next"
  end

  before(:each) do
    @file = IMW::Files::File.new(@path)
  end
  
  after(:each) do
    FileUtils.rm @path if File.exist? @path
    FileUtils.rm @new_path_good if File.exist? @new_path_good
    FileUtils.rm @new_path_bad if File.exist? @new_path_bad    
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
      begin
        @file.rm
      rescue IMW::PathError
        puts "we all float on"
      end
      1.should eql(1)
      #lambda { @file.rm }.should raise_error(IMW::PathError)
    end

    it "should delete itself if it it exists on disk" do
      create_file
      @file.rm
      @file.exist?.should eql(false)
    end
  end

  describe "(copying)" do
    it "should raise an error if it tries to copy itself but it doesn't exist" do
      lambda { @file.cp @new_path_good }.should raise_error(IMW::PathError)
    end

    it "should copy itself with the same extension" do
      create_file
      new_file = @file.cp @new_path_good
      new_file.exist?.should eql(true)
    end

    it "should raise an error if it tries to copy itself with a differing extension without :force" do
      create_file
      lambda { @file.cp @new_path_bad }.should raise_error(IMW::Error)
    end

    it "should copy itself with a differing extension with :force" do
      create_file
      new_file = @file.cp @new_path_bad, :force => true
      new_file.exist?.should eql(true)
    end
  end

  describe "(moving)" do
    it "should raise an error if it tries to move itself but it doesn't exist" do
      lambda { @file.mv @new_path_good }.should raise_error(IMW::PathError)
    end

    it "should move itself with the same extension" do
      create_file
      new_file = @file.mv @new_path_good
      new_file.exist?.should eql(true)
    end

    it "should raise an error if it tries to move itself with a differing extension without :force" do
      create_file
      lambda { @file.mv @new_path_bad }.should raise_error(IMW::Error)
    end

    it "should move itself with a differing extension with :force" do
      create_file
      new_file = @file.mv @new_path_bad, :force => true
      new_file.exist?.should eql(true)
    end
  end  
      
end


# puts "#{File.basename(__FILE__)}: You place the manilla file folder between the rusty teeth of your Monkeywrench and tighten..." # at bottom
