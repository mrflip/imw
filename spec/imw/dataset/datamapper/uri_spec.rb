require File.join(File.dirname(__FILE__),'../../../spec_helper')
require File.join(File.dirname(__FILE__),'../datamapper_spec_helper')
include IMW
require 'imw/dataset/datamapper/uri'

if IMW::SpecConfig::TEST_WITH_DATAMAPPER
  IMW::SpecConfig.setup_datamapper_test_db
  describe IMW do
    
    before(:each) do
      DM_URI.all.each do |u| u.destroy  end
    end

    it "makes a URI from a barely complete string" do
      DM_URI.find_or_create_from_url('google.com')
      u = DM_URI.first
      u.should_not be_nil
      u.host.should == 'google.com'
    end

    it "behaves as normalized" do
      DM_URI.find_or_create_from_url('google.com')
      u = DM_URI.first
      u.path.should   == '/'
      u.scheme.should == 'http'
      u.port.should   be_nil
    end

    it "makes a complicated URI from a complicated string" do
      DM_URI.find_or_create_from_url('http://me:and@your.mom.com:69/what?orly=yarly&ok=then')
      dm_uri = DM_URI.first({
          :scheme => 'http', :host => 'your.mom.com', :port => '69',
          :query => 'what?orly=yarly&ok=then'
        })
    end

    # it converts to a file path
    # it doesn't leave a trailing / on the file path
    # it escapes unicode URLs
    # it escapes non-URL chars in URL
  end

end
