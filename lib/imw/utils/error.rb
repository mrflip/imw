#
# h2. lib/imw/utils/error -- errors
#
# == About
#
# Error objects for IMW.
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

  class TypeError < TypeError
  end

  class ArgumentError < ArgumentError
  end

  class NotImplementedError < NotImplementedError
  end

  # An error meant to be used when a system call goes awry.  It will
  # report exit status and the process id of the offending call.
  class SystemCallError < IMW::Error

    def initialize(message)
      @message = message
    end

    def display
      "(error code: #{$?.exitstatus}, pid: #{$?.pid}) #{@message}"
    end

    def to_s
      "(error code: #{$?.exitstatus}, pid: #{$?.pid}) #{@message}"
    end

  end

  # A error for improperly specified, inappropriate, or broken paths.
  class PathError < IMW::Error
  end

end
