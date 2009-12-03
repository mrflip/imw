require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Packager do
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
    
    @files.each do |path| # do not create @txt on purpose
      IMWTest::Random.file path
    end
  end


  describe "when preparing files" do
    before do
      @packager = IMW::Packager.new @name, @files
      @packager.prepare!      
    end

    after do
      FileUtils.rm_rf @packager.tmp_dir
    end

    it "should name its archive directory properly" do
      @packager.tmp_dir.should contain(@name)
    end

    it "should copy regular files to its archive directory" do
      @packager.archive_dir.should contain(@csv, @xml, @txt)
    end

    it "should uncompress compressed files to its archive directory" do
      @packager.archive_dir.should     contain('foobar-bz2')
      @packager.archive_dir.should_not contain(@bz2)
    end

    it "should copy the content of archive files to its archive directory (but not the actual archives)" do
      @archives.each do |archive|
        @packager.archive_dir.should_not contain(archive)
        @packager.archive_dir.should contain(*IMW.open(archive).contents)
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
      
      @packager = IMW::Packager.new @name, @renaming_hash
      @packager.prepare!
    end

    after do
      FileUtils.rm_rf @packager.tmp_dir
    end

    it "should copy regular files to its archive directory, renaming them" do
      @packager.archive_dir.should_not contain([@csv, @xml, @txt])
      @packager.archive_dir.should contain([@csv, @xml, @txt].map { |f| @renaming_hash[f] })
    end

    it "should uncompress compressed files to its archive directory, renaming them" do
      @packager.archive_dir.should     contain('foobar_bz2')
      @packager.archive_dir.should_not contain('foobar-bz2')      
      @packager.archive_dir.should_not contain(@renaming_hash[@bz2])
      @packager.archive_dir.should_not contain(@bz2)
    end
  end

  describe "when packaging files" do
    before do
      @packager = IMW::Packager.new @name, @files
      @packager.prepare!

      @package_tarbz2 = "package.tar.bz2"
      @package_zip    = "package.zip"
      @packages = [@package_tarbz2, @package_zip]
    end

    after do
      FileUtils.rm_rf @packager.tmp_dir
    end

    it "should create a package file containing the proper files" do
      @packages.each do |package|
        @packager.package package
        @packager.tmp_dir.should contain(IMW.open(package).contents)
      end
    end
  end
end

