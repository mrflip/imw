#
# h2. lib/imw/utils/error -- errors
#
# == About
#
# Error objects for IMW>
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 


module IMW

  # A generic error class.
  class Error < StandardError
  end

  # An error meant to be used when a system call goes awry.  It reports the exit code of the call as well as the 
  class SystemCallError < RuntimeError

    attr_reader :command
    
    def initialize(command)
      self.message = "(error code: #{$?.exitstatus}, pid: #{$?.pid}) #{command}"
    end

  end
  
  
end
