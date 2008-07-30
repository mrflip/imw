#
# h2. lib/imw/utils/extensions/array.rb -- array extensions
#
# == About
#
# Extensions to the +Array+ class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require "ostruct"

class Array

  # Return all but the last  element
  # This will be [] for both an empty array and a length-1 array
  def most() self[0..-2] end 

  # Return all but the first element.
  # This will be nil for an empty array and [] for a length-1 array
  def rest() self[1..-1] end 
  
  # 'Un'-zip()s an array.  Returns an array of arrays: the first array has the
  # first element of each member, the second array has the second element of
  # each member, and so on.  Returns as many arrays as the first element in self
  # and inserts a nil where the member array wasn't long enough.
  #
  # foo, bar = foo.zip(bar).unzip should leave foo and bar with the same values
  # if foo and bar have the same length.
  # 
  # Will fail on a not-array-of-arrays.
  def unzip()
    # An array of empty arrays, one for each vertical slot
    vslices = self[0].map{ Array.new }
    self.each do |hslice| 
      # push the elements of each array onto its slice.
      vslices.zip(hslice).map{|vslice,h_el| vslice << h_el }
    end
    vslices
  end

  # Return a random element of this array.
  def random_element
    self[rand(self.length) - 1]
  end

  # convert an assoc (list of [key, val, [...]]'s) to a hash
  def to_openstruct
    mapped = {}
    each{ |key,value| mapped[key] = value.to_openstruct }
    OpenStruct.new(mapped)
  end

  # Return the elements of this array in a pretty-printed string,
  # inserting +final_string+ between the last two items.
  # 
  #   >> [:one, :two, :three].quote_keys "or"
  #   `one', `two', or `three'
  #   
  def quote_items final_string = nil
    string_items = self.map { |item| "`" + item.to_s + "'" }
    case string_items.length
    when 0
      ""
    when 1
      string_items.first
    when 2
      if final_string then
        string_items.join(" #{final_string} ")
      else
        string_items.join(', ')
      end
    else
      string = string_items[0,string_items.length - 1].join ', '
      if final_string then
        string += ', ' + final_string + ' ' + string_items.last
      else
        string += ', ' + string_items.last
      end
      string
    end
  end
end

# puts "#{File.basename(__FILE__)}: I have a loooong list of complaints.  Firstly, ..." # at bottom
