#
# h2. spec/imw/model/files/compressible_spec.rb -- spec for compressible module
#
# == About
#
# Defines shared example groups ("a file compressible by bzip2", "a
# file compressible by gzip") for the
# <tt>IMW::Files::Compressible</tt> module to be included in specs for
# classes which mixin the <tt>IMW::Files::Compressible</tt> module.
# The specs for these classes should define, for each example, the
# following instance variables:
#
# <tt>@file</tt>:: an object to be compressed which is a subclass of
# <tt>IMW::Files::BasicFile</tt>.
#
# <tt>@copy_of_original_path</tt>:: a string giving a path where a
# copy of <tt>@file</tt> can be made for comparison purposes.
#
# The including spec should also define a method +create_file+ for
# creating a real file at the path corresponding to <tt>@file</tt>.
#
# The including spec must handle the +before+ and +after+ clauses for
# the creation and removal of files and directories; this spec doesn't
# handle those details.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
require File.join(File.dirname(__FILE__),'../../../spec_helper')
require IMW_SPEC_DIR+'/imw/matchers/directory_contents_matcher'
require IMW_SPEC_DIR+'/imw/matchers/file_contents_matcher'
require 'imw/utils/random'

share_examples_for "a file compressible by bzip2" do

  describe "when compressing with bzip2" do
    before(:each) do
      @program = :bzip2
    end

    it_should_behave_like "a file compressible by a given program"
  end
end

share_examples_for "a file compressible by gzip" do
  describe "when compressing with gzip" do
    before(:each) do
      @program = :gzip
    end

    it_should_behave_like "a file compressible by a given program"
  end
end

share_examples_for "a file compressible by a given program" do

  include Spec::Matchers::IMW

  describe "and discarding original file" do

    it "should raise an error when compressing a non-existing file" do
      lambda { @file.compress! @program }.should raise_error(IMW::PathError)
    end

    it "should compress itself to the correct path" do
      create_file
      compressed_file = @file.compress! @program
      compressed_file.exist?.should eql(true)
    end

    it "should not exist after compressing itself" do
      create_file
      compressed_file = @file.compress! @program
      @file.exist?.should eql(false)
    end
  end

  describe "and keeping original file" do
    it "should raise an error when compressing a non-existing file" do
      lambda { @file.compress @program }.should raise_error(IMW::PathError)
    end

    it "should compress itself to the correct path" do
      create_file
      compressed_file = @file.compress @program
      compressed_file.exist?.should eql(true)
    end

    it "should be identical to the way it was before it was compressed" do
      create_file
      @file.cp @copy_of_original_path
      compressed_file = @file.compress @program
      @file.path.should have_contents_matching_those_of(@copy_of_original_path)
    end
  end
end

# puts "#{File.basename(__FILE__)}: Is it squishy?  Give it a squeeze and see!" # at bottom
