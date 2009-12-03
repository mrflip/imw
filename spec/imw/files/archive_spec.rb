#
# h2. spec/imw/model/files/archive_spec.rb -- module for use in testing various archive formats
#
# == About
#
# The <tt>IMW::Files::Archive</tt> module doesn't implement any
# functionality of its own but merely adds methods to an including
# class.  Appropriately, this spec file implements a shared example
# group ("an archive of files")  which can be including
# by the spec of an archive class.  This spec must also define the
# following instance variables:
#
# <tt>@archive</tt>:: a subclass of <tt>IMW::Files::BasicFile</tt> which
# has the <tt>IMW::Files::Archive</tt> module mixed in.
#
# <tt>@root_directory</tt>: a string specifying the path where all the
# files will be created
#
# <tt>@initial_directory</tt>: a string specifying the path where some
# files for the initial creation of the archive will be created.
#
# <tt>@appending_directory</tt>: a string specifying the path where
# all some files for appending to the archive will be created.
#
# <tt>@extraction_directory</tt>: a string specifying the path where
# the archive's files will be extracted.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/matchers/archive_contents_matcher'
require IMW_SPEC_DIR+'/imw/matchers/directory_contents_matcher'

require 'imw/utils/random'
require 'imw/utils/extensions/find'
share_examples_for "an archive of files" do
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
end unless defined? IMW_FILES_ARCHIVE_SHARED_SPEC

# puts "#{File.basename(__FILE__)}: How many drunken frat boys can fit in an Internet kiosk?" # at bottom
