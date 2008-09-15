#!/usr/bin/env ruby
require 'rubygems'
require 'active_support'

class MigrateFucker
  attr_accessor :klass
  attr_accessor :props
  attr_accessor :rels
  def initialize klass
    self.klass = klass
    @props = []
    @rels  = []
  end
  def add_prop prop
    self.props << prop
  end
  def add_rel  prop
    self.rels << prop
  end

  def to_s
    returning([]) do |s|
      s << "class #{klass}\n  include DataMapper::Resource\nproperty      :id,                            Integer,  :serial => true"
      s << props_to_s
      s << rels_to_s
      s << "end"
    end
  end
  def props_to_s() props.join("\n")  end
  def rels_to_s()  rels.join("\n")   end
end

def join_pretty what, type, prop, *rest
  mods = rest.compact.in_groups_of(2).map{|k,v| "%-12s => %-7s" % [k,(v||'')+',']}
  mods = mods.join('') unless mods.blank?
  type  = type.classify
  type += ',' if !mods.blank?
  str = "  %-13s\t%-31s %-15s%s" % [what, prop+',', type, mods].compact
  str.gsub(/(,\s*),/, '\\1').gsub(/,\s*$/,'')
end

EXTENDED_ARGS_RE = %r{(?:,\s*([^,]+)\s*=>\s*([^,]+))}
MACRO_RE         = %r{belongs_to|has_one|has_many|has_and_belongs_to_many|has_many}
MACRO_TR = {'belongs_to'=>'belongs_to', 'has_one' => 'has 1,', 'has_many' => 'has n,'}
migrator_order = []
migrators      = {}
klass = ''
$stdin.readlines.each do |line|
  line.chomp!
  case
  when line =~ %r{class\s+(?:Create)?(\w+)\s+<\s+ActiveRecord::Migration}
    klass = $1.singularize
    if !migrators.include?(klass)
      migrator_order << klass
      migrators[klass] = MigrateFucker.new(klass)
    end

  when line =~ %r{class\s+(\w+)\s+<\s+ActiveRecord::Base}
    klass = $1
    if !migrators.include?(klass)
      migrator_order << klass
      migrators[klass] = MigrateFucker.new(klass)
    end

  when m = (%r{t\.(\w+)\s+(:\w+)#{EXTENDED_ARGS_RE}*\s*$}.match(line))
    migrators[klass].add_prop join_pretty(:property, *(m.to_a[1..-1].compact))

  when m=(%r{add_column\s+:(\w+),\s+(:\w+),\s+:(\w+)#{EXTENDED_ARGS_RE}*\s*}.match(line))
    _, table, prop, type, *rest = m.to_a
    migrators[table.classify].add_prop join_pretty(:property, type, prop, *rest)

  when m=(%r{t\.timestamps}.match(line))
    migrators[klass].add_prop join_pretty(:property, 'DateTime', ':created_at')
    migrators[klass].add_prop join_pretty(:property, 'DateTime', ':updated_at')

  when m=(%r{(#{MACRO_RE})\s+(:\w+)#{EXTENDED_ARGS_RE}*\s*}.match(line))
    _, macro, prop, *rest = m.to_a
    migrators[klass].add_rel  join_pretty(macro, '', prop, *rest)

  when m=(%r{def\s*self\.down}.match(line))
    klass = ''
  else
  end
end

migrator_order.each do |klass|
  puts migrators[klass].to_s
end
