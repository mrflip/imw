#
# h2. imw/test/imw/utils/validate_test.rb -- unit tests for imw/lib/utils/validate.rb
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'test/unit'
require 'imw/utils/validate'

class ValidateTest < Test::Unit::TestCase

  def test_is_domain()
    valid_domains = ['GOOGLE.com','www.google.com','maths.ox.ac.uk','infochimps.org','DHRUVBANSAL.com','everything2.com','zic.bc','psp-spot.com','www-3.psp-spot.com']
    invalid_domains = ['@me.com','silly_buckets.foolishness.com','wefw=230=','', 'com']

    # FIXME are 'com' or 'oneword' sufficient as domain names? (No -- flip)

    valid_domains.each   { |domain| assert is_domain?(domain), "Failed to accept valid domain: #{domain}" }
    invalid_domains.each { |domain| assert !is_domain?(domain), "Failed to reject invaild domain: #{domain}" }
  end

  def test_is_email()
    valid_emails = ['SimianSally@bananasrus.com','BanzoBond007@mi6.uk','123_.456r178ej@robomonkey.com','ab_cd@example-one.com','_underscore@literally.com','a@monkey.info']
    invalid_emails = ['Bad.bonzo.com','TrailingDot.@quite.literally.edu','Double..Dots@yummy.biz','','@']

    valid_emails.each { |email| assert is_email?(email), "Failed to accept valid email: #{email}" }
    invalid_emails.each { |email| assert !is_email?(email), "Failed to reject invaild email: #{email}" }
  end
end

puts "#{File.basename(__FILE__)}: But who validates the test that validates the test?" # at bottom
