#
# h2. spec/imw/model/files/archive_spec.rb -- module for use in testing various archive formats
#
# == About
#
# The IMW::Files::Archive module doesn't implement any functionality
# of its own but merely adds methods to an including class.
# Appropriately, this spec file implements a collection of functions
# useful for testing archive types but doesn't actually implement any
# tests.  An including spec must define the +archive+ instance
# variable and gains the +create_random_files+ and
# +delete_random_files+ methods which should be used in +before+ and
# +after+ blocks, respectively.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'fileutils'
require 'set'

require 'imw/utils'
require 'imw/utils/random'
require 'imw/utils/extensions/find'

require 'rubygems'
require 'spec'

require 'imw/model/directory_spec'

share_as :ARCHIVE_COMMON_SPEC do

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
end

module Spec
  module Matchers
    module IMW

      # Match the contents of the archive against files or directories
      # in +paths+.
      #
      # Options include:
      # 
      # <tt>:relative_to</tt>:: a leading path which will be stripped
      # from all +paths+ before comparison with the contents of the
      # directory.
      class ArchiveContentsMatchPaths

        private
        def initialize paths,opts = {}
          opts.reverse_merge!({:relative_to => nil})
          paths = [paths] if paths.class == String
          @paths = paths
          @relative_to = opts[:relative_to]
          find_paths_contents
        end

        def find_paths_contents
          # find all the files
          contents = []
          @paths.each do |path|
            path = File.expand_path path
            if File.file? path then
              contents << path
            elsif File.directory? path then
              contents += Find.files_in_directory(path)
            end
          end

          # strip leading path
          contents.map! do |path|
            # the +1 is because we want a relative path
            path = path[@relative_to.length + 1,path.size]
          end

          @paths_contents = contents.to_set
        end

        def pretty_print set
          set.to_a.join("\n\t")
        end
        
        public
        def matches? archive
          @archive = archive
          @archive_contents = @archive.contents.to_set
          @archive_contents == @paths_contents
        end

        def failure_message
          missing_from_archive = "missing from archive:\n\t#{pretty_print(@paths_contents - @archive_contents)}\n"
          missing_from_paths = "missing from paths:\n\t#{pretty_print(@archive_contents - @paths_contents)}\n"
          common = "common to both:\n\t#{pretty_print(@archive_contents & @paths_contents)}\n"
          "expected contents of archive (#{@archive.path}) and paths (#{@paths.join(", ")}) to be identical.\n#{missing_from_archive}\n#{missing_from_paths}\n#{common}"
        end

        def negative_failure_message
          "expected contents of archive (#{@archive.path}) and paths (#{@paths.join(", ")}) to differ."
        end
        
      end

      # Invokes the matcher <tt>Spec::Matchers::IMW::ArchiveContentsMatchPaths
      def contain_paths_like paths, opts = {}
        ArchiveContentsMatchPaths.new(paths,opts)
      end
    end
  end
end

# puts "#{File.basename(__FILE__)}: How many drunken frat boys can fit in an Internet kiosk?" # at bottom
