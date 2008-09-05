#
# h2. spec/imw/workflow/rip/local_spec.rb -- specs for copying files from local disk
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR + "/imw/matchers/without_regard_to_order_matcher.rb"

require 'fileutils'

require 'imw/utils/random'
require 'imw/utils/extensions/find'
require 'imw/workflow/rip/local'

describe "Ripping from local disk" do

  include Spec::Matchers::IMW

  before(:all) do
    @root_directory = IMW::DIRECTORIES[:dump] + "/local_spec"
    @file1 = @root_directory + "/first.csv"
    
    @source_directory1 = @root_directory + "/source1"
    @file2 = @source_directory1 + "/second.txt"
    @file3 = @source_directory1 + "/third.csv"

    @source_directory2 = @root_directory + "/source2"
    @file4 = @source_directory2 + "/fourth.txt"
    @file5a = @source_directory2 + "/fifth-shared.yaml"

    @source_directory3 = @source_directory2 + "/source3-nested"
    @file5b = @source_directory3 + "/fifth-shared.yaml"
    
    @target_directory = @root_directory + "/target"
  end

  before(:each) do
    FileUtils.mkdir([@root_directory,@source_directory1,@source_directory2,@source_directory3,@target_directory])
    [@file1,@file2,@file3,@file4,@file5a,@file5b].each {|file| IMW::Random.file(file)}
  end

  after(:each) do
    FileUtils.rm_rf @root_directory
  end


  def basenames_of files
    files.map {|file| File.basename file}
  end
  
  it "should raise an error when attempting to copy to a non-existent target directory" do
    FileUtils.rm_rf @target_directory
    lambda { IMW::Rip.from_local_disk(@target_directory,@source_directory1)}.should raise_error(IMW::PathError)
  end

  it "should copy all files in all directories and paths recursively to the target directory without any hierarchy" do
    IMW::Rip.from_local_disk(@target_directory,@file1,@source_directory1,@source_directory2)
    Find.files_relative_to_directory(@target_directory).should match_without_regard_to_order(basenames_of([@file1,@file2,@file3,@file4,@file5a]))
  end

  it "should accept a block which establishes a hierarchy to be created in the target directory and which skips copying certain files if it returns nil" do

    # complicated block to copy files to sub-directories of the target
    # directory depending on their extension
    IMW::Rip.from_local_disk(@target_directory,@file1,@source_directory1,@source_directory2) do |path|
      if File.extname(path) == '.txt' then
        File.join('txt',File.basename(path)) # put text files in txt
      elsif File.extname(path) == '.csv' then
        File.join("csv",File.basename(path)) # put csv files in csv
      else
        nil # don't copy other extensions
      end
    end

    # what we would expect to see from that block
    txt = [@file2,@file4].map {|path| File.join("txt",File.basename(path))}
    csv = [@file1,@file3].map {|path| File.join("csv",File.basename(path))}

    Find.files_relative_to_directory(@target_directory).should match_without_regard_to_order(txt + csv)
  end
      
end

# puts "#{File.basename(__FILE__)}: Having found the platter you were looking for, you stare at it, examining your reflection.  What a handsome chimp you are!" # at bottom
