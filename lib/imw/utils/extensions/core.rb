require 'imw/utils/extensions/string'
require 'imw/utils/extensions/array'
require 'imw/utils/extensions/hash'
require 'imw/utils/extensions/dir'
require 'imw/utils/extensions/struct'
require 'imw/utils/extensions/symbol'
require 'imw/utils/extensions/file_core'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/misc'
#require 'active_support/core_ext/blank.rb'
require 'imw/utils/extensions/class/attribute_accessors'
# require 'ostruct'
require 'set'

module IMW
  # A replacement for the standard system call which raises an
  # IMW::SystemCallError if the command fails as well as printing the
  # command appended to the end of <tt>error_message</tt>.
  def self.system *commands
    Kernel.system(*commands)
    raise IMW::SystemCallError.new(command) unless $?.success?
  end
end


