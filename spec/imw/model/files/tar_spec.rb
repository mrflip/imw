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

require 'fileutils'

require 'rubygems'
require 'spec'

require 'imw/model/files/tar'
require 'imw/utils'
require 'imw/utils/random'

require 'imw/model/files/archive_spec'
require 'imw/model/directory_spec'

describe IMW::Files::Tar do

  include ARCHIVE_COMMON_SPEC
  include Spec::Matchers::IMW


  def create_random_files
    IMW::Random.directory_with_files(@initial_directory)
    IMW::Random.directory_with_files(@appending_directory)
    FileUtils.mkdir(@extraction_directory)
  end

  def delete_random_files
    FileUtils.rm_rf [@root_directory,@extraction_directory]
  end

  before(:each) do
    @root_directory = ::IMW::DIRECTORIES[:tmp] + "/archive_test"
    @initial_directory = @root_directory + "/create_and_append/initial"
    @appending_directory = @root_directory + "/create_and_append/appending"
    @extraction_directory = ::IMW::DIRECTORIES[:tmp] + "/extract"
    @archive = IMW::Files::Tar.new(@root_directory + "/test.tar")
    create_random_files    
  end

  after(:each) do
    delete_random_files
    FileUtils.rm(@archive.path) if @archive.exist?
  end

  describe "(listing)" do
    it "should raise an error when listing a non-existent archive" do
      lambda { @archive.contents }.should raise_error(IMW::Error)
    end
  end
  
  describe "(creation)" do
    
    it "should be able to create archives which match a directory's structure" do
      @archive.create(@initial_directory + "/*")
      @archive.should contain_paths_like(@initial_directory, :relative_to => @root_directory)
    end

    it "should raise an error if trying to overwrite an archive without the :force option" do
      @archive.create(@initial_directory + "/*")
      lambda { @archive.create(@initial_directory + "/*") }.should raise_error(IMW::Error)
    end

    it "should overwrite an archive if the :force option is given" do
      @archive.create(@initial_directory + "/*")
      @archive.create(@initial_directory + "/*", :force => true)      
      @archive.should contain_paths_like(@initial_directory, :relative_to => @root_directory)
    end
  end
  
  describe "(appending)" do

    it "should append to an archive which already exists" do
      @archive.create(@initial_directory + "/*")
      @archive.append(@appending_directory + "/*")
      @archive.should contain_paths_like([@initial_directory,@appending_directory], :relative_to => @root_directory)
    end

    it "should append to an archive which doesn't already exist" do
      @archive.append(@appending_directory + "/*")
      @archive.should contain_paths_like(@appending_directory, :relative_to => @root_directory)
    end

  end

  describe "(extracting)" do

    it "should raise an error when trying to extract from a non-existing archive" do
      lambda { @archive.extract }.should raise_error(IMW::Error)
    end

    it "should extract files which match the original ones it archived" do
      @archive.create(@initial_directory + "/*")
      @archive.append(@appending_directory + "/*")      
      new_archive = @archive.cp(@extraction_directory + '/' + @archive.basename)
      new_archive.extract
      @extraction_directory.should contain_files_matching_directory(@root_directory)
    end
      
  end

end

# puts "#{File.basename(__FILE__)}: The tar pits are just /wonderful/ today; really, you should go in for a dip!" # at bottom
