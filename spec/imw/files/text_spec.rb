require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Files::Text do

  before do
    @path = "foobar.txt"
    @text = <<EOF
Here is the first line
And here is the second
EOF
    File.open(@path, 'w') { |f| f.write(@text) }
  end

  it "should return its entries" do
    IMW.open(@path).entries.should == ["Here is the first line", "And here is the second"]
  end

  it "should be able to parse each line" do
    file = IMW.open(@path)
    results = file.parse :by_regexp => /^([^\s]+) ([^\s]+)/, :into_fields => [:word1, :word2]
    file.parser.class.should == IMW::Parsers::RegexpParser
  end
end
