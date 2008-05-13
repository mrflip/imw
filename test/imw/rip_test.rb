#
# h2. imw/foo -- desc lib
#
# action::    desc action     
#
# == Tests for imw/rip.rb
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'test/unit'
require 'imw/rip'

class RipTest < Test::Unit::TestCase

  def test_reverse_domain()
    # valid urls
    assert 'com.example' == reverse_domain("http://www.example.com/and/then/some"),'Failed to accept valid URI: "http://www.example.com/and/then/some"'
    assert 'com.example' == reverse_domain("www.example.com/and/then/some"),'Failed to accept valid URI: "www.example.com/and/then/some"'
    assert 'com.example' == reverse_domain("http://example.com/and/then/some"),'Failed to accept valid URI: "http://example.com/and/then/some"'
    assert 'com.example' == reverse_domain("example.com/and/then/some"),'Failed to accept valid URI: "example.com/and/then/some"'
    assert 'com.example' == reverse_domain("example.com"),'Failed to accept valid URI: "example.com"'

    # real urls (pulled from websites -- really ugly...)
    #  grabbed this one from a great discussion at 
    #  http://actsasblog.wordpress.com/2006/10/16/url-validation-in-rubyrails/
#    assert 'com.target' == reverse_domain("http://www.target.com/gp/detail.html/602-4045909-4263801?ASIN=B000NPCK3W&AFID=Froogle&LNM=B000NPCK3W|Lexmark_AllInOne_Printer_with_Scanner_and_Copier__X1240&ci_src=14110944&ci_sku=B000NPCK3W&ref=tgt_adv_XSG10001"),'Failed to accept valid URI: "http://www.target.com/gp/detail.html/602-4045909-4263801?ASIN=B000NPCK3W&AFID=Froogle&LNM=B000NPCK3W|Lexmark_AllInOne_Printer_with_Scanner_and_Copier__X1240&ci_src=14110944&ci_sku=B000NPCK3W&ref=tgt_adv_XSG10001"'
    assert 'com.wordpress.actsasblog' == reverse_domain("http://actsasblog.wordpress.com/2006/10/16/url-validation-in-rubyrails/"), 'Failed to accept valid URI: "http://actsasblog.wordpress.com/2006/10/16/url-validation-in-rubyrails/"'

    # numeric urls
    assert '127.0.0.1' == reverse_domain("http://127.0.0.1/index.html"), 'Failed to accept valid URI: "http://127.0.0.1/index.html"'
    assert '127.0.0.1' == reverse_domain("127.0.0.1/index.html"), 'Failed to accept valid URI: "127.0.0.1/index.html"'

    # invalid urls that we should throw away
    assert_raise URI::InvalidURIError, 'Failed to reject invalid URI: "http://"' do reverse_domain("http://") end
    assert_raise URI::InvalidURIError, 'Failed to reject invalid URI: "http:"' do reverse_domain("http:") end
#    assert_raise URI::InvalidURIError, 'Failed to reject invalid URI: "http:/"' do reverse_domain("http:/") end
  end
end

puts "#{File.basename(__FILE__)}: You test the balance of your Infinite Monkeywrench in your hand as you contemplate ripping through vast jungles of data." # at bottom
