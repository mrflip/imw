#
# h2. lib/imw/utils/extensions/core.rb -- extensions to the Ruby core
#
# == About
#
# Some useful extensions to basic Ruby classes.  This file is required
# by <tt>imw/utils</tt> so any files required here are automatically
# required when loading IMW.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Your monkeywrench does a complicated series of core-burning exercises and emerges with ripped, powerful-looking abs."

require 'imw/utils/extensions/string'
require 'imw/utils/extensions/array'
require 'imw/utils/extensions/hash'
require 'imw/utils/extensions/dir'
require 'imw/utils/extensions/struct'
require 'imw/utils/extensions/symbol'
require 'imw/utils/extensions/file_core'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/blank.rb'
require 'imw/utils/extensions/class/attribute_accessors'
# require 'ostruct'
require 'set'

module IMW
  # A replacement for the standard system call which raises an
  # IMW::SystemCallError if the command fails as well as printing the
  # command appended to the end of <tt>error_message</tt>.
  def self.system(command, error_message = nil)
    Kernel.system(command)
    message = error_message ? "#{error_message} (#{command})" : command
    raise IMW::SystemCallError.new(message) unless $?.success?
  end
end


