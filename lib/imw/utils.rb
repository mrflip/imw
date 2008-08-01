#
# h2. lib/imw/utils.rb -- utility functions
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/utils/error'
require 'imw/utils/config'
require 'imw/utils/paths'
require 'imw/utils/extensions/core'

# puts "#{File.basename(__FILE__)}: Early economists thought they would measure the utility of an action in units of `utils'.  Really." # at bottom

module IMW
  class << self; attr_accessor :verbose end
  def announce str
    return unless IMW.verbose
    puts "#{Time.now}\t" + str.to_s
  end
  def banner str
    return unless IMW.verbose
    puts "*"*75
    announce str
    puts "*"*75
  end

end
