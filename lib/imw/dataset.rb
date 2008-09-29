# -*- coding: utf-8 -*-
require 'imw/dataset/datamapper'
require 'imw/dataset/datamapper/time_and_user_stamps'
# Dir[File.dirname(__FILE__)+'/dataset/*'].each{|f| require f }
require 'imw/dataset/infochimps_resource'
require 'imw/dataset/link'
require 'imw/dataset/asset'
require 'imw/dataset/dataset'


#
# Datamapper interface to infochimps
#

class Contributor
  include DataMapper::Resource
  include Infochimps::Resource
  # include Sluggable
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 255,          :nullable => false, :default => ''
  has_handle
  alias_method  :handle_generator, :name
  has_time_and_user_stamps
  #
  property      :url,                           String,         :length      => 255,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  property      :base_trustification,           Integer,                                              :default => 0
  #
  has n,        :credits
  has n,        :datasets,    :through => :credits
  has n,        :taggings,                            :child_key => [:tagger_id]
  has n,        :tags,        :through => :taggings,  :child_key => [:tagger_id]
  has n,        :taggables,   :through => :taggings,  :child_key => [:tagger_id], :class_name => 'Dataset'
  #
  # Macros
  #
  # self.slug_on :url
end

class Credit
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  has_time_and_user_stamps
  has_handle
  def handle_generator()  [dataset_id, contributor_id, role].join '-' end
  #
  property      :dataset_id,                    Integer
  property      :contributor_id,                Integer
  #
  property      :role,                          String,         :length      =>  40,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  property      :citation,                      Text,                                   :nullable => false, :default => ''
  #
  belongs_to    :dataset
  belongs_to    :contributor
end

class Linking
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  has_handle
  def handle_generator()  [linkable_type, linkable_id, link_id, role].join '-' end
  has_time_and_user_stamps
  #
  property      :linkable_id,                   Integer,                                                                        :index => :linkable_index
  property      :link_id,                       Integer,                                                                        :index => :linkable_index
  property      :role,                          String,         :length      =>  40,    :nullable => false, :default => '',     :index => :linkable_index
  property      :linkable_type,                 String,         :length      =>  40,    :nullable => false,                     :index => :linkable_index
  #
  belongs_to    :linkable, :class_name => 'Dataset', :child_key => [:linkable_id],       :polymorphic  => true
  belongs_to    :link
end

class Tagging
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  has_handle
  def handle_generator()  [taggable_type, taggable_id, tagger_type, tagger_id, tag_id].join '-' end
  has_time_and_user_stamps
  #
  property      :context,                       String,         :length      =>  40,    :nullable => false, :default => ''
  property      :tag_id,                        Integer
  property      :taggable_id,                   Integer
  property      :taggable_type,                 String,         :length      =>  40,    :nullable => false
  #
  property      :tagger_id,                     Integer
  property      :tagger_type,                   String
  #
  belongs_to    :tagger,   :class_name => 'Contributor', :child_key => [:tagger_id],        :polymorphic  => true
  belongs_to    :taggable, :class_name => 'Dataset',     :child_key => [:taggable_id],      :polymorphic  => true
  belongs_to    :tag
  before :save, :fake_tagger_polymorphism; def fake_tagger_polymorphism() self.tagger_type ||= 'Contributor' end
end

class Tag
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 255,    :nullable => false, :default => ''
  has_handle                                                    :length      => 255
  alias_method  :handle_generator, :name
  #
  has n,        :taggings
  has n,        :taggables, :through => :taggings
  has n,        :taggers,   :through => :taggings
end

class Note
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  property      :name,                          String,         :length      => 255,    :nullable => false, :default => ''
  has_handle
  def handle_generator()  [noteable_type, noteable_id, role].join '-' end
  has_time_and_user_stamps
  #
  property      :noteable_id,                   Integer
  property      :noteable_type,                 String,         :length      =>  40,    :nullable => false
  property      :role,                          String,         :length      =>  40,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  #
  belongs_to    :noteable, :class_name => 'Dataset', :child_key => [:noteable_id],       :polymorphic  => true
  before :save, :fake_polymorphism; def fake_polymorphism() self.noteable_type = 'Dataset' end
end

class Rating
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  has_handle
  def handle_generator()  [rateable_type, rateable_id, context].join '-' end
  has_time_and_user_stamps
  #
  property      :user_id,                       Integer
  property      :rateable_id,                   Integer
  property      :rateable_type,                 String,         :length      =>  40,    :nullable => false
  #
  property      :rating,                        Integer,                                                    :default => 0
  property      :context,                       String,         :length      =>  40,    :nullable => false, :default => "overall"
  #
  belongs_to    :rateable, :class_name => 'Dataset', :child_key => [:rateable_id],      :polymorphic  => true
  belongs_to    :user
  before :save, :fake_polymorphism; def fake_polymorphism() self.rateable_type = 'Dataset' end
end

class License
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  property      :name,                          String,         :length      => 255,    :nullable => false, :default => ''
  has_handle
  alias_method  :handle_generator, :name
  has_time_and_user_stamps
  #
  property      :url,                           String,         :length      => 255,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  #
  has n,        :license_infos
  has n,        :datasets,      :through => :license_infos
end

class LicenseInfo
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  has_handle
  def handle_generator()  [dataset_id, license_id].join '-' end
  has_time_and_user_stamps
  #
  property      :dataset_id,                    Integer
  property      :license_id,                    Integer
  #
  property      :url,                           String,         :length      => 255,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  #
  belongs_to    :license
  belongs_to    :dataset
end

class Payload
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  property      :file_name,                     String,         :length      => 150,    :nullable => false, :default => ''
  property      :file_path,                     String,         :length      => 2048,   :nullable => false, :default => ''
  has_handle
  alias_method  :handle_generator, :file_path
  has_time_and_user_stamps
  #
  property      :dataset_id,                    Integer
  #
  property      :file_date,                     DateTime
  property      :format,                        String,         :length      => 40,     :nullable => false, :default => ''
  property      :shape,                         String
  property      :size,                          Integer
  property      :stats,                         Text
  #
  property      :signature,                     Text
  property      :signed_by,                     Integer
  property      :fingerprint,                   String,         :length      => 40,     :nullable => false, :default => ''
  #
  belongs_to    :dataset
end

class Field
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  has_handle
  def handle_generator()  [dataset_id, name].join '-' end
  has_time_and_user_stamps
  #
  property      :dataset_id,                    Integer
  property      :table_id,                      Integer
  #
  property      :name,                          String,         :length      => 150,    :nullable => false, :default => ''
  property      :desc,                          Text,                                   :nullable => false, :default => ''
  property      :datatype,                      String,         :length      =>  40,    :nullable => false, :default => ''
  property      :representation,                String,         :length      => 255,    :nullable => false, :default => ''
  property      :concepts,                      String,         :length      => 255,    :nullable => false, :default => ''
  property      :constraints,                   String,         :length      => 255,    :nullable => false, :default => ''
  property      :stats,                         Text,                                   :nullable => false, :default => ''
  belongs_to    :dataset
end

class User
  include DataMapper::Resource
  include Infochimps::Resource
  include DataMapper::Timestamp
  property      :id,                            Integer,        :serial  => true
  property      :login,                         String,         :length  =>  40,        :nullable => false
  has_handle
  alias_method  :handle_generator, :login
  #
  property      :prefs,                         Text
  #
  property      :identity_url,                  String,         :length  => 255,        :nullable => false, :unique      => true
  property      :name,                          String,         :length  => 100,        :nullable => false
  property      :email,                         String,         :length  => 100,        :nullable => false
  property      :email_is_public,               Boolean,                                              :default => false
  property      :homepage_link,                 String,         :length  => 255,        :nullable => false, :default     => ''
  property      :blurb,                         Text,           :length  =>2048,        :nullable => false, :default     => ''
  #
  property      :public_key,                    Text
  property      :email_verification_code,       String,         :length  => 40
  property      :email_verified_at,             DateTime
  property      :roles,                         String,         :length  => 2048
end
