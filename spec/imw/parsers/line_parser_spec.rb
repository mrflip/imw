require File.dirname(__FILE__) + "/../../spec_helper"
require 'ostruct'

describe IMW::Parsers::LineParser do

  before do
    @path = File.dirname(__FILE__) + "/../../data/sample.csv"
    @file = File.new(@path)
    @fields = [:id, :name, :genus, :species]
  end

  describe "without an implemented parsing method" do

    before do
      @parser = IMW::Parsers::LineParser.new
    end
    
    it "should raise an error when attempting to parse a line" do
      lambda { @parser.parse_line "wahtever" }.should raise_error(IMW::NotImplementedError)
    end

  end

  describe "with an implemented parsing method" do

    before do

      @parser_class = Class.new(IMW::Parsers::LineParser)
      @parser_class.class_eval do
        def parse_line line
          id, name, genus, species = line.chomp.split(',')
          { :id => id, :name => name, :genus => genus, :species => species }
        end
      end

      @parser = @parser_class.new
    end

    it "should skip lines as needed" do
      @parser.skip_first = 1
      results = @parser.parse!(@file)
      results.length.should == 130
    end

    it "should read as many lines as it's asked" do
      results = @parser.parse!(@file, :lines => 10)
      results.length.should == 10
    end

    describe "when parsing into hashes" do
    
      it "should return an array of hashes when called without a block" do
        results = @parser.parse!(@file)
        results.length.should == 131
        results.first.should == { :id => "ID", :name => "Name", :genus => "Genus", :species => "Species" }
      end

      it "should pass each hash to a block when given one" do
        results = returning([]) do |array|
          @parser.parse!(@file) do |hsh|
            hsh.delete(:id)
            array << hsh
          end
        end
        results.length.should == 131
        results.first.should == { :name => "Name", :genus => "Genus", :species => "Species" }
      end
    end

    describe "when parsing into objects" do
      before { @parser.klass = OpenStruct }

      it "should return an array of objects when defined with a class" do
        results = @parser.parse!(@file)
        results.length.should == 131
        results.first.class.should == OpenStruct
      end
      
      it "should pass each object to a block when given one and defined with a class" do
        @parser.klass = OpenStruct
        results = returning([]) do |array|
          @parser.parse!(@file) do |obj|
            obj.genus = nil
            array << obj
          end
        end
        results.length.should == 131
        results.first.class.should == OpenStruct
        results.first.genus.should be_blank
      end
    end
  end
end



