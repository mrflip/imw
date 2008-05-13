#
# h2. imw/tasks/db/schema -- desc lib
#
# action::    desc action     
#
# == About
#
# Author::    Philip flip Kromer for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 


# This file is taken from the infochimps site code

ActiveRecord::Schema.define(:version => 12) do
  do_migrate ||= IMWConfig::Config['migrate']

  if do_migrate 
    create_table "tinyfuckers", :force => true  do |t|
      t.integer   "ID #"
      t.string    "name"
      t.string    "car"
    end 
    
    create_table "pools",        :force => true do |t|
      t.string   "uniqname",                                       :default => "", :null => false
      t.string   "name",                                           :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.text     "formats",                                        :default => "", :null => false
      t.text     "cached_tag_list"
      
      # has_many    :datasets
      # has_many    :fields,        :through => pool_fields        #( notes )
      # has_many    :contributors,  :through => pool_contributors  #( notes )
      # has_many    :pool_notes
      # serialize   :formats
      #
    end 
    add_index "pools", ["uniqname"],      :name => "idx_pool_uniqname", :unique => true

    create_table "datasets", :force => true do |t|
      t.string   "uniqname",                                       :default => "", :null => false
      t.string   "name",                                           :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.integer  "dnloaded_count",                                 :default => 0,  :null => false    
      t.text     "cached_tag_list"
      t.text     "fileinfo",                                       :default => "", :null => false
      t.string   "collection_id",                                  :default => "", :null => false

      t.integer  "pool_id"
      # belongs_to  :pool
      # has_many    :fields,        :through => dataset_fields
      # has_many    :contributors,  :through => dataset_contributors
      # has_many    :dataset_notes
      # serialize   :fileinfo
      #
    end
    add_index "datasets", ["uniqname"],   :name => "idx_dataset_uniqname", :unique => true

    create_table "contributors", :force => true do |t|
      t.string   "uniqname",                                       :default => "", :null => false
      t.string   "name",                                           :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.text     "desc",       :default => "",        :null => false
      t.string   "cite",       :default => "",        :null => false
      t.string   "url",        :default => ""
      t.string   "role"
      
      # has_many    :pools,         :through =>    pool_contributors
      # has_many    :datasets,      :through => dataset_contributors
      #
    end
    add_index "contributors", ["uniqname"], :name => "idx_contributor_uniqname", :unique => true
    add_index "contributors", ["url"],      :name => "idx_contributor_url"
    add_index "contributors", ["role"],     :name => "idx_contributor_role"
    create_table "dataset_contributors", :id => false, :force => true do |t|
      t.integer "contributor_id", :null => false
      t.integer "dataset_id",     :null => false
      t.integer "desc",           :null => false
    end
    add_index "dataset_contributors", ["contributor_id", "dataset_id"], :name => "idx_dc_contributor_id", :unique => true
    add_index "dataset_contributors", ["dataset_id"],                   :name => "idx_dc_dataset_id"
    create_table "pool_contributors", :id => false, :force => true do |t|
      t.integer "contributor_id", :null => false
      t.integer "pool_id",        :null => false
      t.integer "desc",           :null => false
    end
    add_index "pool_contributors",    ["contributor_id", "pool_id"],    :name => "idx_pc_contributor_id", :unique => true
    add_index "pool_contributors",    ["pool_id"],                      :name => "idx_pc_pool_id"

    create_table "fields", :force => true do |t|
      t.string   "uniqname",   :default => "",        :null => false
      t.string   "name",       :default => "",        :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.text     "desc",       :default => "",        :null => false
      t.string   "concepts",   :default => "",        :null => false
      t.string   "units",      :default => "",        :null => false
      t.string   "datatype",   :default => "",        :null => false
      
      # has_many    :pools,         :through =>    pool_fields
      # has_many    :datasets,      :through => dataset_fields
      #
    end
    add_index "fields", ["uniqname"], :name => "idx_field_uniqname"
    create_table "dataset_fields", :id => false, :force => true do |t|
      t.integer "field_id",     :default => "",       :null => false
      t.integer "dataset_id",   :default => "",       :null => false
      t.integer "desc",         :default => "",       :null => false
    end
    add_index "dataset_fields", ["field_id", "dataset_id"], :name => "idx_df_field_id", :unique => true
    add_index "dataset_fields", ["dataset_id"],             :name => "idx_df_dataset_id"
    create_table "pool_fields", :id => false, :force => true do |t|
      t.integer "field_id",     :default => "",       :null => false
      t.integer "pool_id",      :default => "",       :null => false
      t.integer "desc",         :default => "",       :null => false
    end
    add_index "pool_fields",    ["field_id", "pool_id"],    :name => "idx_pf_field_id", :unique => true
    add_index "pool_fields",    ["pool_id"],                :name => "idx_pf_pool_id"

    create_table "dataset_notes", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.integer  "dataset_id",                 :null => false
      t.string   "label",      :default => "", :null => false
      t.text     "note",       :default => "", :null => false
      
      # belongs_to :dataset
      #
    end
    add_index "dataset_notes", ["dataset_id", "label"], :name => "idx_dsnote_dataset_notes", :unique => true
    add_index "dataset_notes", ["label"],               :name => "idx_dsnote_uniqname"

    create_table "pool_notes", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      
      t.integer  "pool_id",                    :null => false
      t.string   "label",      :default => "", :null => false
      t.text     "note",       :default => "", :null => false
      
      # belongs_to :pool
      #
    end
    add_index "pool_notes", ["pool_id", "label"],    :name => "idx_plnote_dataset_notes", :unique => true
    add_index "pool_notes", ["label"],               :name => "idx_plnote_uniqname"

    create_table "tags", :force => true do |t|
      t.string   "name",          :limit => 150, :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "tags", ["name"], :name => "idx_tag_name", :unique => true

    create_table "taggings", :id => false, :force => true do |t|
      t.integer  "tag_id",                        :null => false
      t.integer  "taggable_id",                   :null => false
      t.string   "taggable_type", :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "idx_tagging_id", :unique => true
    add_index "taggings", ["taggable_id", "taggable_type"],           :name => "idx_tagging_taggable_id"
    add_index "taggings", ["taggable_type"],                          :name => "idx_tagging_taggable_type"

  end # do_migrate
end # ActiveRecord::Schema
