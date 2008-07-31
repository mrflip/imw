require File.join(File.dirname(__FILE__),'../../spec_helper')
require 'imw/utils/paths'

include IMW

describe IMW do
  before(:each) do
    @paths = {
      :data    => '/data',
      :weather => 'ftp.ncdc.noaa.gov/pub/data/noaa',
      :first   => ['1', :second, 'last'],
      :second  => ['2', :third],
      :third   => ['3'],
    }
    stub!(:paths).and_return @paths
  end

  it 'is idempotent on a string' do
    path_to('hi').should == 'hi'
  end

  it 'has an absolute path to the data dir' do
    path_to(:data).should =~ %r{^/}
  end

  it 'handles mixed array and sym args' do
    path_to( [:data, 'hi'], [[['there']]]).should == '/data/hi/there'
  end

  it 'expands to later generations' do
    path_to(:first).should == File.join('1/2/3/last')
  end

  it 'expands interior symbols' do
    path_to(['hadoop1:/working', :data, :weather]).should ==
      File.join('hadoop1:/working/data/ftp.ncdc.noaa.gov/pub/data/noaa')
  end

end
