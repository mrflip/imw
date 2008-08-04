#
# h2. spec/imw/utils/extensions/find_spec.rb -- spec for find.rb
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR + "/imw/matchers/without_regard_to_order_matcher"

require 'fileutils'
require 'set'

require 'imw/utils'
require 'imw/utils/random'
require 'imw/utils/extensions/find'

describe Find do

  include Spec::Matchers::IMW

  def create_sample_files
    FileUtils.mkdir_p(@subsubdirectory)
    [@file1,@file2,@file3,@file4,@file5,@file6].each {|path| IMW::Random.file path}
  end

  before(:all) do
    @root_directory = IMW::DIRECTORIES[:dump] + "/find_extension_spec"
    @subdirectory = @root_directory + "/subdir"
    @subsubdirectory = @subdirectory + "/subsubdir"
    @file1 = @root_directory + "/my_file1.txt"
    @file2 = @root_directory + "/my_file2.csv"
    @file3 = @root_directory + "/my_file3.dat"
    @file4 = @subdirectory + "/your_file4.html"
    @file5 = @subdirectory + "/your_file5.csv"
    @file6 = @subdirectory + "/your_file6"
  end

  before(:each) do
    create_sample_files
  end

  after(:each) do
    FileUtils.rm_rf @root_directory
  end

  describe "when listing files with absolute paths contained in a directory" do

    it "should find every file by default" do
      Find.files_in_directory(@root_directory).should match_without_regard_to_order([@file1,@file2,@file3,@file4,@file5,@file6])
    end

    it "should only find files which match its :include argument" do
      Find.files_in_directory(@root_directory, :include => /.*\.csv$/).should match_without_regard_to_order([@file2,@file5])
    end

    it "should not find files which match its :exclude argument" do
      Find.files_in_directory(@root_directory, :exclude => /.*\.csv$/).should match_without_regard_to_order([@file1,@file3,@file4,@file6])
    end

    it "should only find files which match its :include argument and don't match its :exclude argument" do
      Find.files_in_directory(@root_directory, :include => /my/, :exclude => /.*\.csv$/).should match_without_regard_to_order([@file1,@file3])
    end
  end

  describe "when listing files with relative paths contained in a directory" do

    def strip_root_directory array
      array.map {|item| item[@root_directory.length + 1,item.size]}
    end

    it "should find every file by default" do
      Find.files_relative_to_directory(@root_directory).should match_without_regard_to_order(strip_root_directory([@file1,@file2,@file3,@file4,@file5,@file6]))
    end

    it "should only find files which match its :include argument" do
      Find.files_relative_to_directory(@root_directory, :include => /.*\.csv$/).should match_without_regard_to_order(strip_root_directory([@file2,@file5]))
    end

    it "should not find files which match its :exclude argument" do
      Find.files_relative_to_directory(@root_directory, :exclude => /.*\.csv$/).should match_without_regard_to_order(strip_root_directory([@file1,@file3,@file4,@file6]))
    end

    it "should only find files which match its :include argument and don't match its :exclude argument" do
      Find.files_relative_to_directory(@root_directory, :include => /^my/, :exclude => /.*\.csv$/).should match_without_regard_to_order(strip_root_directory([@file1,@file3]))
    end

  end
    
end

# puts "#{File.basename(__FILE__)}: You throw your Monkeywrench backwards over your shoulder and run like mad to go find it.  Again, and again, and again." # at bottom
