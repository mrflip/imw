#
# h2. lib/imw/utils/extensions/symbol.rb -- extensions to symbol class
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

class Symbol

  # Turn the symbol into a simple proc (stolen from
  # <tt>ActiveSupport::CoreExtensions::Symbol</tt>).
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end

  # Returns the symbol itself (for compatibility with
  # <tt>String.uniqnae</tt> and so on.
  def uniqname
    self
  end
  
end

# puts "#{File.basename(__FILE__)}: You whisper a word of power and smile as the the Ruby Palace thunders with the sound of falling blocks." # at bottom
