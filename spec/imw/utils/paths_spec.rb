require File.join(File.dirname(__FILE__),'../../spec_helper')
require 'imw'
require 'imw/utils/paths'

describe IMW do
  include IMW
  before(:each) do
    IMW::PATHS = {
      :data    => '/data',
      :weather => 'ftp.ncdc.noaa.gov/pub/data/noaa',
      :first   => ['1', :second, 'last'],
      :second  => ['2', :third],
      :third   => ['3'],
    }
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
