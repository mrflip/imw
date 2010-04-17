require File.join(File.dirname(__FILE__),'../../spec_helper')
require File.join(File.dirname(__FILE__), 'archive_spec')

describe IMW::Files::Tarbz2 do
  before do
    @extension = '.tar.bz2'
  end
  it_should_behave_like "an archive of files"

  it "should correctly set its extension" do
    IMW.open('foo.tar.bz2').extname.should == '.tar.bz2'
  end

  it "should recognize the correct file class from a basename" do
    IMW::Files::file_class_for('foo.tar.bz2').should == IMW::Files::Tarbz2
  end
end



