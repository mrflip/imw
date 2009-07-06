#
# h2. lib/imw/utils/extensions/string.rb -- string extensions
#
# == About
#
# Implements some useful extensions to the +String+ class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

class String

  # Does the string end with the specified +suffix+ (stolen from
  # <tt>ActiveSupport::CoreExtensions::String::StartsEndsWith</tt>)?
  def ends_with?(suffix)
    suffix = suffix.to_s
    self[-suffix.length, suffix.length] == suffix
  end

  # Does the string start with the specified +prefix+ (stolen from
  # <tt>ActiveSupport::CoreExtensions::String::StartsEndsWith</tt>)?
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end

  # # Downcases a string and replaces spaces with underscores.  This
  # # works slightly differently than
  # # <tt>ActiveSupport::CoreExtensions::String::Inflections.underscore</tt>
  # # which is intended to be used for camel-cased Ruby constants.
  # #
  # #   "A long and unwieldy phrase".underscore #=> "a_long_and_unwieldy_phrase"
  # def underscore
  #   self.to_s.tr("-", "_").tr(" ","_").downcase
  # end

  # Returns the handle corresponding to this string as a symbol:
  #
  #   "A possible title of a dataset".handle #=> :a_possible_title_of_a_dataset
  def to_handle
    self.downcase.underscore.to_sym
  end

end

# puts "#{File.basename(__FILE__)}: You tie a long string to your Monkeywrench, place it on the ground, and hide around the corner with the string in your hand, waiting for passersby to try and make a grab for it." # at bottom
