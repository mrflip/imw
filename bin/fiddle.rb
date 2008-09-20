#!/usr/bin/env ruby

require 'imw'

schema  = YAML.load(File.open($imw.path_to(:code_etc,'skel/schema-example.icss.yaml')))

schema_in = schema[0]['infochimps_schema']
# schema_in['handle'] ||= schema_in.delete('uniqid')

#puts schema_in.to_yaml
ds = Collection.from_icss(schema_in)
puts "=======================\n"
#puts ds.to_icss.to_yaml
puts  ds.to_csv.to_yaml

puts IMWStruct.ids.to_yaml
