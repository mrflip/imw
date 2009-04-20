#
# h2. lib/imw/utils/misc.rb -- miscellaneous functions
#
# == About
#
# A collection of helpful functions in various places through the IMW
# source tree.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

# Removed by flip
#
# def identify(obj)
#   obj.hash
# end

module IMW
  # Return a string representing the current UTC time in the IMW
  # format.
  def self.current_utc_time_string
    Time.now.utc.strftime(IMW::STRFTIME_FORMAT)
  end


  # A simple counter.  The +value+ and +add+ methods read and
  # increment the counter's value.
  #
  #   counter = IMW::Counter.new
  #   counter.value  #=> 0
  #   counter.add 1
  #   counter.value  #=> 1
  #
  # The +next!+ method acts as like C's <tt>value++</tt>, incrementing
  # +value+ _after_ it is referenced.
  #
  #   counter = IMW::Counter.new
  #   counter.value  #=> 0
  #   counter.next!  #=> 0
  #   counter.value  #=> 1
  #
  # Counters can also be reset
  # 
  #   counter.reset!
  #   counter.value  #=> 0
  class Counter

    attr_accessor :value, :starting_value, :increment

    # Return a new Counter.  The first argument is the starting value
    # (defaults to 0) and the second is the increment (defaults to 1).
    def initialize starting_value=0,increment=1
      @starting_value = starting_value
      @value          = starting_value
      @increment      = increment
    end

    # Add +amount+ (defaults to the value of <tt>@increment</tt>).
    def add amount=nil
      @value += amount || @increment
    end
    alias_method :add!, :add

    # Increment the counter by <tt>@increment</tt> but return its
    # value _before_ being incremented.
    def next!
      old_value = @value      
      @value += @increment
      old_value
    end

    # Reset the counter to +value+ (defaults to the value of
    # <tt>@starting_value</tt>).
    def reset! value=nil
      @value = value || @starting_value
    end
  end
end

# puts "#{File.basename(__FILE__)}: Your Monkeywrench seems suddenly more utilisable." # at bottom
