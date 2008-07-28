#
# h2. lib/imw/utils/core_extensions.rb -- extensions to the Ruby core
#
# == About
#
# Some useful extensions to basic Ruby objects.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require "ostruct"


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
end

class Hash

  # Stolen from ActiveSupport::CoreExtensions::Hash::ReverseMerge
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  # Stolen from ActiveSupport::CoreExtensions::Hash::ReverseMerge
  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end


  # Create a hash from an array of keys and corresponding values.
  def self.zip(keys, values, default=nil, &block)
    hash = block_given? ? Hash.new(&block) : Hash.new(default)
    keys.zip(values) { |k,v| hash[k]=v }
    hash
  end

  # Turns a collection of pairs into a hash.  The first of each pair make the
  # keys and the second the values. Elements with length longer than two will
  # lose those values.
  # 
  # If there are multiple values of 
  #
  def from_pairs()
    hsh = { }
    self.each{ |k,v| hsh[k] = v }
    hsh
  end

  # Merges self with another hash, recursively.
  # 
  # first  = {
  #   :balls=> "monkey",
  #   :data=> {
  #     :name=> {:first=> "Sam", :middle=>"I", :last=>"am"}}}
  # second = {
  #   :data=> {
  #     :name=> {:middle=>["you", "me", "everyone we know"], :last => "are"}},
  #   1    => [1,2,5] }
  #
  # p first.deep_merge(second)
  # # => {:data=>{:name=>{:last=>"are", :middle=>["you", "me", "everyone we know"], :first=>"Sam"}}, 1=>[1, 2, 5], :balls=>"monkey"}
  # from http://snippets.dzone.com/posts/show/4706 
  # From: http://pastie.textmate.org/pastes/30372, Elliott Hird
  def deep_merge(second)
    target = dup
    second.keys.each do |key|
      if second[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(second[key])
      else
        target[key] = second[key]
      end
    end
    target
  end


  # Merges self in-place with another hash, recursively.
  #
  # first  = {
  #   :balls=> "monkey",
  #   :data=> {
  #     :name=> {:first=> "Sam", :middle=>"I", :last=>"am"}}}
  # second = {
  #   :data=> {
  #     :name=> {:middle=>["you", "me", "everyone we know"], :last => "are"}},
  #   1    => [1,2,5] }
  #
  # p first.deep_merge(second)
  # # => {:data=>{:name=>{:last=>"are", :middle=>["you", "me", "everyone we know"], :first=>"Sam"}}, 1=>[1, 2, 5], :balls=>"monkey"}
  #
  # From: http://www.gemtacular.com/gemdocs/cerberus-0.2.2/doc/classes/Hash.html
  # File lib/cerberus/utils.rb, line 42
  def deep_merge!(second)
    second.keys.each do |key|
      if second[key].is_a?(Hash) and self[key].is_a?(Hash)
        self[key].deep_merge!(second[key])
      else
        self[key] = second[key]
      end
    end
    self
  end

  #
  # merge another array with this one, accumulating values that appear in both
  # into arrays.
  #
  # Note: array values will be flatten'ed. Sorry.
  #
  # first  = {
  #   :balls=> "monkey",
  #   :data=> {
  #     :name=> {:first=> "Sam", :middle=>"I", :last=>"am"}}}
  # second = {
  #   :data=> {
  #     :name=> {:middle=>["you", "me", "everyone we know"], :last => "are"}},
  #   1    => [1,2,5] }
  #
  # p first.deep_merge(second)
  # # => {:data=>{:name=>{:last=>"are",         :middle=>["you", "me", "everyone we know"],      :first=>"Sam"}}, 1=>[1, 2, 5], :balls=>"monkey"}
  # p first.keep_merge(second)
  # # => {:data=>{:name=>{:last=>["am", "are"], :middle=>["I", "you", "me", "everyone we know"], :first=>"Sam"}}, 1=>[1, 2, 5], :balls=>"monkey"}
  #
  def keep_merge(second)
    target = dup
    second.each do |key, val2|
      if second[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].keep_merge(val2)
      else
        target[key] = target.include?(key) ? [target[key], val2].flatten.uniq : val2
      end
    end 
    target
  end
  
  #
  # This is polymorphic to Array#assoc -- that is, it allows you treat a Hash
  # and an array of pairs equivalently using assoc(). We remind you that Array#assoc
  #
  #   "Searches through an array whose elements are also arrays comparing obj
  #    with the first element of each contained array using obj.== . Returns the
  #    first contained array that matches (that is, the first associated array)
  #    or nil if no match is found. See also Array#rassoc."
  #
  # Note that this returns an /array/ of [key, val] pairs. 
  #
  def assoc(key)
    self.include?(key)   ? [key, self[key]] : nil
  end
  def rassoc(key)
    self.has_value?(key) ? [key, self[key]] : nil
  end
  
end

#
# Array
#
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
  #
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
  
  
end

#
# Allow loading an openstruct directly from YAML
#
class Object 
  # Allows loading ostruct directly from YAML
  def to_openstruct() self end 
end
class Array  
  # convert an assoc (list of [key, val, [...]]'s) to a hash
  def to_openstruct
    mapped = {}
    each{ |key,value| mapped[key] = value.to_openstruct }
    OpenStruct.new(mapped)
  end
  
  # Allows loading ostruct directly from YAML
end
class Hash 
  # Allows loading ostruct directly from YAML
  def to_openstruct
    map{ |el| el.to_openstruct }
  end
end
module YAML
  # Load ostruct directly from YAML
  def self.load_openstruct(source)
    self.load(source).to_openstruct
  end
end

class Class

  # Return an ordered list of this class's superclasses.
  def superclasses
    s = self.superclass
    supers = []
    while s
      supers << s
      s = s.superclass
    end
    supers
  end

end

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



# puts "Your monkeywrench does a complicated series of core-burning exercises and emerges with ripped, powerful-looking abs."
