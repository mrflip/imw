#
# h2. lib/imw/utils/extensions/hash.rb -- hash extensions
#
# == About
#
# Extensions to the built-in +Hash+ class.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require "ostruct"
require 'set'

class Hash
  # Return the elements of this hash in a pretty-printed string,
  # inserting +final_string+ between the last two items.
  # 
  #   >> {:one => 1, :two => 2, :three => 3}.quote_keys_with "or"
  #   `one', `two', or `three'
  #   
  def quote_keys_with final_string = nil
    self.keys.quote_items_with final_string
  end

  # Stolen from ActiveSupport::CoreExtensions::Hash::ReverseMerge.
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end
  
  # Stolen from ActiveSupport::CoreExtensions::Hash::ReverseMerge.
  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end
  
  # Create a hash from an array of keys and corresponding values.
  def self.zip(keys, values, default=nil, &block)
    hash = block_given? ? Hash.new(&block) : Hash.new(default)
    keys.zip(values) { |k,v| hash[k]=v }
    hash
  end
  
  # Turns a collection of pairs into a hash.  The first of each pair
  # make the keys and the second the values. Elements with length
  # longer than two will lose those values.
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
      if second[key].is_a?(Hash) && self[key].is_a?(Hash)
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
      if second[key].is_a?(Hash) && self[key].is_a?(Hash)
        self[key].deep_merge!(second[key])
      else
        self[key] = second[key]
      end
    end
    self
  end
  
  # Merge another array with this one, accumulating values that appear in both
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
  def keep_merge(second)
    target = dup
    second.each do |key, val2|
      if second[key].is_a?(Hash) && self[key].is_a?(Hash)
        target[key] = target[key].keep_merge(val2)
      else
        target[key] = target.include?(key) ? [target[key], val2].flatten.uniq : val2
      end
    end
    target
  end

  # This is polymorphic to Array#assoc -- that is, it allows you treat a Hash
  # and an array of pairs equivalently using assoc(). We remind you that Array#assoc
  #
  #   "Searches through an array whose elements are also arrays comparing obj
  #    with the first element of each contained array using obj.== . Returns the
  #    first contained array that matches (that is, the first associated array)
  #    or nil if no match is found. See also Array#rassoc."
  #
  # Note that this returns an /array/ of [key, val] pairs.
  def assoc(key)
    self.include?(key)   ? [key, self[key]] : nil
  end
  def rassoc(key)
    self.has_value?(key) ? [key, self[key]] : nil
  end
  
  # Allows loading ostruct directly from YAML
  def to_openstruct
    map{ |el| el.to_openstruct }
  end


  # Slice a hash to include only the given keys. This is useful for
  # limiting an options hash to valid keys before passing to a method:
  #
  #   def search(criteria = {})
  #     assert_valid_keys(:mass, :velocity, :time)
  #   end
  #
  #   search(options.slice(:mass, :velocity, :time))
  # Returns a new hash with only the given keys.
  def slice(*keys)
    allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    reject { |key,| !allowed.include?(key) }
  end

  # Replaces the hash with only the given keys.
  def slice!(*keys)
    replace(slice(*keys))
  end


end

# puts "#{File.basename(__FILE__)}: To each improvement there corresponds another, yes?" # at bottom
