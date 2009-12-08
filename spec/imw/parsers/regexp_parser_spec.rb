require File.dirname(__FILE__) + "/../../spec_helper"
require 'ostruct'

describe IMW::Parsers::RegexpParser do

  before do
    @path = "foobar.dat"
    @text = <<EOF
151.199.53.145 14-Oct-2007:13:34:34-0500 GET /phpmyadmin/main.php HTTP/1.0
81.227.179.120 14-Oct-2007:13:34:34-0500 GET /phpmyadmin/libraries/select_lang.lib.php HTTP/1.0
81.3.107.173 14-Oct-2007:13:54:26-0500 GET / HTTP/1.1
EOF
    File.open(@path, 'w') { |f| f.write(@text) }
    @file = File.new(@path)

    @regexp = %r{^([\d\.]+) (\d{2}-\w{3}-\d{4}:\d{2}:\d{2}:\d{2}-\d{4}) (\w+) ([^\s]+) HTTP/([\d.]{3})$}
    @fields = [:ip, :timestamp, :verb, :url, :version]

    @parser = IMW::Parsers::RegexpParser.new :by_regexp => @regexp, :into_fields => @fields    
  end
  
  it "should return the proper hash from each row" do
    results = @parser.parse!(@file)
    results.length.should == 3
    results.first.should == {:ip => '151.199.53.145', :timestamp => '14-Oct-2007:13:34:34-0500', :verb => 'GET', :url => '/phpmyadmin/main.php', :version => "1.0"}
  end
end

