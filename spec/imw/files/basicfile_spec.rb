require File.dirname(__FILE__) + "/../../spec_helper"

require "imw"

describe IMW::Files::BasicFile do

  describe "when local" do
    before do
      @path = "foobar.txt"
      IMWTest::Random.file @path
      @file = IMW.open(@path)
      @new_path = "foobar2.txt"
      @new_dir = "bazbaz"
      FileUtils.mkdir_p(@new_dir)      
    end

    it "should now that it's local" do
      @file.local?.should be_true
    end

    it "knows the parts of its URI" do
      @file.host.should     == nil
      @file.path.should     == File.join(IMWTest::TMP_DIR, @path)
      @file.dirname.should  == IMWTest::TMP_DIR
      @file.basename.should == @path
      @file.extname.should  == ".txt"
      @file.name.should     == "foobar"
    end

    it "can copy itself to a new path" do
      @file.cp(@new_path).exist?.should be_true
    end

    it "can move itself to a new path" do
      @file.mv(@new_path).exist?.should be_true
      @file.exist?.should be_false
    end

    it "can delete itself" do
      @file.rm!
      @file.exist?.should be_false
    end

    it "can copy itself to a directory" do

      @file.cp_to_dir(@new_dir)
      @new_dir.should contain(@path)
      @path.should exist      
    end

    it "can move to a directory" do
      @file.mv_to_dir(@new_dir)
      @new_dir.should contain(@path)
      @path.should_not exist
    end

    [:executable?, :executable_real?, :file?, :directory?, :ftype, :owned?, :pipe?, :readable?, :readable_real?, :setgid?, :setuid?, :size, :size?, :socket?, :split, :stat, :sticky?, :writable?, :writable_real?, :zero?].each do |method|
      it "should respond to #{method}" do
        @file.send(method).should == File.send(method, @file.path)
      end
    end
  end


  describe "when remote" do
    before do
      @path = "http://www.google.com"      
      @file = IMW.open(@path)
      
      @new_path = "foobar2.txt"

      @new_dir = "bazbaz"
      FileUtils.mkdir_p(@new_dir)
      
    end

    it "should know that it's remote" do
      @file.local?.should be_false
      @file.remote?.should be_true
    end

    it "knows the parts of its URI" do
      @file.host.should == "www.google.com"
      @file.path.should == ''
      @file.dirname.should == '.'
      @file.basename.should == ''
      @file.extname.should == ''
      @file.name.should == ''
    end

    it "can open the file" do
      @file.should be
      @file.class.should == IMW::Files::Html
    end

    it "should raise an error when trying to write" do
      lambda { IMW.open!(@path) }.should raise_error
    end

    it "can copy a file" do
      @file.cp(@new_path)
      @new_path.should exist
    end

    it "can move a file" do
      @file.mv(@new_path)
      @new_path.should exist
    end

    it "should raise an error when trying to remove" do
      lambda { @file.rm }.should raise_error
    end
  end
end

  
