require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Packagers::Archiver do
  before do
    @name = 'foobar'

    # regular files
    @csv  = "foobar-csv.csv"
    @xml  = "foobar-xml.xml"
    @txt  = "foobar-txt.txt"
    @blah = "foobar"

    # compressed files
    @bz2  = "foobar-bz2.bz2"

    # archives
    @zip      = "foobar-zip.zip"
    @tarbz2   = "foobar-tarbz2.tar.bz2"
    @rar      = "foobar-rar.rar"
    @archives = [@zip, @tarbz2]

    @files = [@csv, @xml, @txt, @blah, @bz2, @zip, @tarbz2]
    
    @files.each do |path|
      IMWTest::Random.file path
    end
  end


  describe "when preparing files" do
    before do
      @archiver = IMW::Packagers::Archiver.new @name, @files
      @archiver.prepare!      
    end

    after do
      FileUtils.rm_rf @archiver.tmp_dir
    end

    it "should name its archive directory properly" do
      @archiver.tmp_dir.should contain(@name)
    end

    it "should copy regular files to its archive directory" do
      @archiver.dir.should contain(@csv, @xml, @txt)
    end

    it "should uncompress compressed files to its archive directory" do
      @archiver.dir.should     contain('foobar-bz2')
      @archiver.dir.should_not contain(@bz2)
    end

    it "should copy the content of archive files to its archive directory (but not the actual archives)" do
      @archives.each do |archive|
        @archiver.dir.should_not contain(archive)
        @archiver.dir.should contain(*IMW.open(archive).contents)
      end
    end

    it "should not move any of the original files" do
      IMWTest::TMP_DIR.should contain(@files)
    end
  end

  describe "when preparing files while renaming them" do
    before do

      # to test renaming, consider the new paths to be the old paths
      # but with the hyphens mapped to underscores...
      @renaming_hash = {}
      @files.each { |f| @renaming_hash[f] = f.gsub(/-/,'_') }
      
      @archiver = IMW::Packagers::Archiver.new @name, @renaming_hash
      @archiver.prepare!
    end

    after do
      FileUtils.rm_rf @archiver.tmp_dir
    end

    it "should copy regular files to its archive directory, renaming them" do
      @archiver.dir.should_not contain([@csv, @xml, @txt])
      @archiver.dir.should contain([@csv, @xml, @txt].map { |f| @renaming_hash[f] })
    end

    it "should uncompress compressed files to its archive directory, renaming them" do
      @archiver.dir.should     contain('foobar_bz2')
      @archiver.dir.should_not contain('foobar-bz2')      
      @archiver.dir.should_not contain(@renaming_hash[@bz2])
      @archiver.dir.should_not contain(@bz2)
    end
  end

  describe "when packaging files" do
    before do
      @archiver = IMW::Packagers::Archiver.new @name, @files
      @archiver.prepare!

      @package_tarbz2 = "package.tar.bz2"
      @package_zip    = "package.zip"
      @packages = [@package_tarbz2, @package_zip]
    end

    after do
      FileUtils.rm_rf @archiver.tmp_dir
    end

    it "should create a package file containing the proper files" do
      @packages.each do |package|
        @archiver.package! package
        @archiver.tmp_dir.should contain(IMW.open(package).contents)
      end
    end

    it "should return the package file" do
      @packages.each do |package|
        output = @archiver.package! package
        output.basename.should == package
      end
    end
    
    
  end
end

