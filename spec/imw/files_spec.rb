require File.dirname(__FILE__) + "/../spec_helper"

require "imw"

describe IMW::Files do

  describe "a local file" do
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
      @file.remote?.should be_false
    end

    it "knows the parts of its URI" do
      @file.host.should == nil
      @file.path.should == File.join(IMWTest::TMP_DIR, @path)
      @file.dirname.should == IMWTest::TMP_DIR
      @file.basename.should == @path
      @file.extname.should == ".txt"
      @file.name.should == "foobar"
    end

    it "can open a file" do
      @file.should be
      @file.class.should == IMW::Files::Text      
    end

    it "can write to a new file" do
      f = IMW.open!(@new_path)
      f.write('whatever')
      f.close
      open(@new_path).read.should == 'whatever'
    end

    it "can copy a file" do
      @file.cp(@new_path)
      @path.should exist
      @new_path.should exist
    end

    it "can move a file" do
      @file.mv(@new_path)
      @path.should_not exist
      @new_path.should exist
    end

    it "can delete a file" do
      @file.rm!
      @path.should_not exist
    end

    it "can copy to a directory" do
      @file.cp_to_dir(@new_dir)
      @new_dir.should contain(@path)
      @path.should exist      
    end

    it "can move to a directory" do
      @file.mv_to_dir(@new_dir)
      @new_dir.should contain(@path)
      @path.should_not exist
    end
    
    
    
  end


  describe "a remote file" do
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
      @file.class.should == IMW::Files::Text      
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

  
