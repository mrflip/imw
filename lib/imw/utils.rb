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

module IMW

  # A replacement for the standard system call which raises an
  # IMW::SystemCallError if the command fails as well as printing the
  # command appended to the end of <tt>error_message</tt>.
  def self.system command, error_message = nil
    system(command)
    raise IMW::SystemCallError.new("#{error_message} (command)") if $?.success?
  end
  
    

# puts "#{File.basename(__FILE__)}: Something clever" # at bottom
