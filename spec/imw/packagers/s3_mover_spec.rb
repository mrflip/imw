require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Packagers::S3Mover do

  before do
    @bucket_name = 'imwtest'
    @mover = IMW::Packagers::S3Mover.new :bucket_name => @bucket_name, :access_key_id => 'foobar', :secret_access_key => 'barbaz'
    @local_path = 'foobar.txt'
    IMWTest::Random.file(@local_path)
    @s3_path = 'foobar.txt'
  end

  it "should upload a file successfully" do
    AWS::S3::S3Object.should_receive(:store).and_return(Net::HTTPOK)
    @mover.upload!(@local_path, @s3_path)
    @mover.success?.should be_true
  end

  it "should recognize an error" do
    AWS::S3::S3Object.should_receive(:store).and_return(Net::HTTPBadRequest)
    @mover.upload!(@local_path, @s3_path)
    @mover.success?.should_not be_true
  end
  
  
end


