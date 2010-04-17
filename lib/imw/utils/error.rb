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

  class ParseError < Error
  end

  # An error meant to be used when a system call goes awry.  It will
  # report exit status and the process id of the offending call.
  class SystemCallError < IMW::Error

    attr_reader :status, :message

    def initialize(status, message)
      @status  = status
      @message = message
    end

    def display
      "(error code: #{status.exitstatus}, pid: #{status.pid}) #{message}"
    end

    def to_s
      "(error code: #{status.exitstatus}, pid: #{status.pid}) #{message}"
    end

  end

  # A error for improperly specified, inappropriate, or broken paths.
  class PathError < IMW::Error
  end

end
