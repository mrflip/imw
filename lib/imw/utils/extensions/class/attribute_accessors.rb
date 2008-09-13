# :nodoc:
# for when cattr_accessor is all you need
#
require 'active_support/core_ext/array/extract_options'
class Array #:nodoc:
  include ActiveSupport::CoreExtensions::Array::ExtractOptions
end
require 'active_support/core_ext/class/attribute_accessors'
