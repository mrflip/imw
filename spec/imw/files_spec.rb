require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Files do

  before do
    @csv   = "foobar.csv"
    @weird = "foobar.awefawefawe"
    @none  = "foobar"

    @files = [@csv, @weird, @none]

    @files.each { |f| IMWTest::Random.file f }

    @new = "newguy.txt"
  end
  
  it "chooses the correct class based upon the extension" do
    IMW.open(@csv).class.should == IMW::Files::Csv
  end

  it "uses Text as a default class when there's a weird or no extension" do
    IMW.open(@weird).class.should == IMW::Files::Text
    IMW.open(@none).class.should == IMW::Files::Text    
  end

  it "will use a different class if asked" do
    IMW.open(@csv, :as => :Text).class.should == IMW::Files::Text
  end
  
  it "can write to a new file" do
    f = IMW.open!(@new)
    f.write('whatever')
    f.close
    open(@new).read.should == 'whatever'
  end
end

  
