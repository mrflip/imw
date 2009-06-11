#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'
require 'csv'
require 'active_support'
# Read from here
inputfile = "#{ENV['HOME']}/ics/data/load/tree/ics_schema_dump.yaml"
# Output to here
outputdir = "/slice/www/infochimps/current/db/load"


#
# Values to indiscriminately stuff in
#
default_dataset_fields = {
  :created_by            => 2,
  :updated_by            => 2,
  :approved_by           => 2,
  :approved              => 1,
  :dnloaded_count        => 0,
}

tablenames = %w{datasets fields contributors notes ratings tags}
table_heads = {
  "datasets"              => %w{ id   created_at  updated_at             uniqid  name        collection  coll_uniqid formats cached_tag_list dnloaded_count  rating_count  rating_total  rating_avg fileinfo}, 
  "contributors"          => %w{ id   created_at  updated_at             uniqid  name  desc  url cite  role        }, 
  "fields"                => %w{ id   created_at  updated_at             uniqid  name  desc  datatype  tags  units }, 
  "notes"                 => %w{ id   created_at  updated_at dataset_id  uniqid  name  desc                        }, 
  "assessments"           => %w{ id   created_at  updated_at dataset_id                type  rating  story created_at  updated_at}, 
  "contributors_datasets" => %w{                             dataset_id  contributor_id   }, 
  "datasets_fields"       => %w{                             dataset_id  field_id  }, 
  "ratings"               => %w{                             rated_id    rater_id       rated_type  rating  }, 
  
  # treated special
  "tags"                  => %w{                             dataset_id  tags  }, 
  
}
  # "tags"                  => %w{ id   created_at  updated_at                     name                 },  
  # "taggings"              => %w{      created_at  updated_at taggable_id tag_id         taggable_type }, 


#
# Loader datafile
#
# datasets     = [];
# contributors = [];
# ratings  = [];
# datafields   = [];
# notes        = [];
# tag_lists    = [];
# fields_datasets       = [];
# contributors_datasets = [];

#
# Array of simple hashes subtree
#
def flatten_association_a(schema, partname, dataset_id)
  part = schema.delete(partname) || []
  part.each do |a_el| 
    a_el['dataset_id'] = dataset_id
  end
  part
end

#
# Hash of simple hashes subtree; stuff hash key in as field
#
def flatten_association_h(schema, partname, dataset_id, keyname='uniqid')
  part = schema.delete(partname) || {}
  # puts part.to_yaml
  part.map do |hkey, h_el| 
    # is is <<name: string>> or <<name: {hash: of, things:hashed}>>?
    h_el    = { 'desc' => h_el.to_s } unless h_el.is_a? Hash
    # tie it to the dataset, and adopt in the sugary name
    h_el['dataset_id'] = dataset_id
    h_el[keyname]      = hkey
    h_el['name']     ||= hkey
    h_el
  end
end

#
# scalar attribute
#
def flatten_association_s(schema, partname, dataset_id)
  part = schema.delete(partname) || ''
  [ { 'dataset_id' => dataset_id, partname => part } ]
end


#
# KLUDGE -- there is nothing about this that is not.
#

def tags_extract(schema, partname, dataset_id)
  # name_tags = schema['name'].gsub(/Table \d+/,'')
  # schema['tags'] += ' '+name_tags
  # # make 10,000 into 10000
  # schema['tags'].gsub!(/\b(\d+),(\d+)\b/, '\1\2')
  # schema['tags'].gsub!(/\W+/, ' ')
  # # kill off years
  # schema['tags'].gsub!(/\b(\d{4})\b/, '')
  # 
  # schema['tags'].gsub!(/ +(\w|and|I|a|about|an|are|as|at|be|by|com|de|en|for|from|how|in|is|it|la|of|on|or|that|the|this|to|was|what|when|where|who|will|with|the)\b/i,
  #                      " ")
  # puts schema['tags']

  flatten_association_s(schema, partname, dataset_id)
end

#
# simple structure, just store it in DB as YAML text
#
def flatten_as_yaml(schema, partname)
  part = schema.delete(partname)
  schema[partname] = part.to_yaml
end

def make_habtm(tables, partname, assocname='dataset')
  # Association table 
  joinname = [partname.pluralize, assocname.pluralize].sort.join('_')
  join = []
  # 
  tables[partname].each do |part|
    join << {
      (partname.singularize()+'_id')  => part['id'], 
      (assocname.singularize()+'_id') => part[assocname+'_id']}
    part.delete(assocname+'_id')
  end
  tables[joinname] = join
end

def id_ify(tables, partname)
  tables[partname].each_with_index do |part,id|
    part['id'] = id+1  # id's count from 0, not 1
  end
end

# def identify(ids, object)
#   true
# end

#
# Walk the schema tree
#
tables     = {}; tablenames.each{ |nm| tables[nm] = [] }
dataset_id = 1 # Rails reserves id 0
YAML::load_documents( File.open( inputfile ) ) do |schemadoc|
  schemadoc.each do |sc_h|
    # look for the schema part of this. 
    schema       = sc_h['infochimps_schema'] or next
    schema['id'] = dataset_id # if !schema.include?('id')
    
    %w{fields contributors}.each do |partname|
      tables[partname] += flatten_association_a(schema, partname, dataset_id) || []      
    end
    partname = 'ratings'; tables[partname] += flatten_association_h(schema, partname, dataset_id) || []
    partname = 'notes';   tables[partname] += flatten_association_h(schema, partname, dataset_id) || []
    
    # %w{tags}.each do |partname|
    #   tables[partname] += flatten_association_s(schema, partname, dataset_id)
    # end
    # KLUDGE
    partname = 'tags';    tables[partname] += tags_extract(schema, partname, dataset_id)
    
    
    %w{formats fileinfo}.each do |partname|
      flatten_as_yaml(schema, partname)
    end
    
    tables['datasets'] << schema
    dataset_id += 1
    puts "%s: Dataset %1d" % [Time.now, dataset_id] if ((dataset_id % 500) == 0)
  end # schema hash
end # document


def dbloader_gen(sql_filename, csv_filename, partname, heads)
  headslist    = heads.map{ |f| "`#{f}`" }.join(", ")
  sql_load_data_str = %Q{
    LOAD DATA INFILE         '#{csv_filename}'
      REPLACE INTO TABLE             `#{partname}`
      FIELDS TERMINATED BY    ','
      ENCLOSED BY             '"'
      ESCAPED BY              '\\\\'
      LINES TERMINATED BY     '\\n'
      IGNORE 1 LINES
      (#{headslist});
  } #}
  File.open(sql_filename, 'wb') do |sql_file| 
    sql_file << sql_load_data_str
  end
end


#
# Dump tags too 
#
yaml_filename = "%s/%s.yaml" % [outputdir, 'tags_lists']
YAML::dump(tables['tags'], File.open(yaml_filename, 'wb'))

def dump_tags(tables)
  # split and uniquify each tag string
  
  # stuff the tags list into the dataset's cached_tag_list
  
  # write the tags table:     tag_id, name
  # write the taggings table: tag_id, taggable_id, taggable_type
end


#
# Output the tables
#
if 1 then
  # Stuff in id's
  (tables.keys - ['datasets']).each{ |partname| id_ify(tables, partname)     }
  # make join tables for habtm relations
  %w{fields contributors}.each{      |partname| make_habtm(tables, partname) }
  
  # Ditch each table into fixture
  tables.each do |partname, parttable|
    parttable.compact!()
    heads  = table_heads[partname]
    rows   = parttable.map{ |row| heads.map{ |head| row[head] } }
    # CSV Fixture
    csv_filename = "%s/%s.csv"      % [outputdir, partname]     
    sql_filename = "%s/load_%s.sql" % [outputdir, partname]     
    puts "%s: Writing to %-25s (%6d rows, cols: [%s])" % [Time.now, partname, rows.length, heads.join("\t")]
    File.open(csv_filename, 'wb') do |csv_file|
      CSV::Writer.generate(csv_file) do |csv| 
        csv << heads
        rows.each{ |row| csv << row }
      end
    end
    # SQL code to load this fixture
    dbloader_gen(sql_filename, csv_filename, partname, heads)
    
  end
end

