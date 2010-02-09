require File.join(File.dirname(__FILE__),'../../spec_helper')

# To use this shared example group define an instance variable
# <tt>@extension</tt> in your tests:
#
#   before do
#     @extension = '.tar.gz'
#   end
#
#   it_should_behave_like "an archive of files"
#
# The <tt>@extension</tt> should obviously be one that maps to a class
# including the <tt>IMW::Files::Archive</tt> module.
share_examples_for "an archive of files" do
  include Spec::Matchers::IMW

  before do
    @root = IMWTest::TMP_DIR
    @initial_directory    = 'foo'
    @appending_directory  = 'bar'
    @extraction_directory = 'baz'
    IMWTest::Random.directory_with_files(@initial_directory)
    IMWTest::Random.directory_with_files(@appending_directory)
    FileUtils.mkdir(@extraction_directory)
    @archive = IMW.open("wakka_wakka#{@extension}") # define @extension in another spec
  end

  it "should be able to create archives which match a directory's structure" do
    @archive.create(*Dir[@initial_directory + "/**/*"])
    @archive.should contain_paths_like(@initial_directory, :relative_to => @root)
  end

  it "should append to an archive which already exists" do
    @archive.create(*Dir[@initial_directory + "/**/*"])
    @archive.append(*Dir[@appending_directory + "/**/*"])
    @archive.should contain_paths_like([@initial_directory,@appending_directory], :relative_to => @root)
  end

  it "should append to an archive which doesn't already exist" do
    @archive.append(*Dir[@appending_directory + "/**/*"])    
    @archive.should contain_paths_like(@appending_directory, :relative_to => @root)
  end

  it "should extract files which match the original ones it archived" do
    @archive.create(*Dir[@initial_directory + "/**/*"])
    FileUtils.cd @extraction_directory do
      @archive.extract
    end
    # FIXME needs its own matcher...
    FileUtils.cd(@extraction_directory) do
      @extracted_files = Dir[@initial_directory + "/**/*"].to_set
    end
    @extracted_files.should == Dir[@initial_directory + "/**/*"].to_set
  end

end
