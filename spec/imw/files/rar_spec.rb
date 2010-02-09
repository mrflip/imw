require File.join(File.dirname(__FILE__),'../../spec_helper')
require File.join(File.dirname(__FILE__), 'archive_spec')

describe IMW::Files::Rar do
  before do
    @extension = '.rar'
  end
  it_should_behave_like "an archive of files"
end



