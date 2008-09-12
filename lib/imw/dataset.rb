require 'rubygems'
require 'dm-ar-finders'
require 'dm-aggregates'
require 'dm-timestamps'
Dir[File.dirname(__FILE__)+'/dataset/*'].each{|f| require f }


module Infochimps
  module Resource
    module ClassMethods
      def has_handle options = { }
        options = { :length => 512 }.merge options
        property      :handle,                      String,         :length      => options[:length], nil => false
      end
      def has_time_and_user_stamps
        property      :created_at,                  DateTime
        property      :updated_at,                  DateTime
        property      :created_by,                  Integer
        property      :updated_by,                  Integer
      end
    end
    def self.included base
      base.extend ClassMethods
      base.property  :uuid,                          String,         :length      =>  32,          nil => false, :unique => true
    end
  end
end


#
# Datamapper interface to infochimps
#
class Dataset
  include DataMapper::Resource
  include Infochimps::Resource
  # include Sluggable;
  # Identity
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 255,          nil => false, :default => ''
  has_handle
  has_time_and_user_stamps
  #
  property      :category,                      String,         :length      =>  50,          nil => false, :default => ''
  property      :collection_id,                 Integer
  property      :is_collection,                 Boolean,        :default     => false
  #
  property      :valuation,                     String,         :default     => "{}"
  property      :metastats,                     String,         :default     => "{}"
  property      :facts,                         String,         :default     => "{}"
  #
  has n,        :credits
  has n,        :contributors, :through     => :credits
  has n,        :notes,                                     :child_key   => [:noteable_id]
  has n,        :links,                                     :child_key   => [:linkable_id]
  has n,        :payloads
  has n,        :ratings,                                   :child_key   => [:rateable_id]
  has 1,        :license_info
  has 1,        :license,     :through     => :license_info
  has n,        :taggings,                                  :child_key => [:taggable_id]
  has n,        :tags,        :through => :taggings,        :child_key => [:taggable_id]
end

class Contributor
  include DataMapper::Resource
  include Infochimps::Resource
  # include Sluggable
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 255,          nil => false, :default => ''
  has_handle
  has_time_and_user_stamps
  #
  property      :url,                           String,         :length      => 255,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  property      :base_trustification,           Integer,                                              :default => 0
  #
  has n,        :credits
  has n,        :datasets,    :through => :credits
  has n,        :taggings,                            :child_key => [:tagger_id]
  has n,        :tags,        :through => :taggings,  :child_key => [:tagger_id]
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
  #
  property      :dataset_id,                    Integer
  property      :contributor_id,                Integer
  #
  property      :role,                          String,         :length      =>  40,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  property      :citation,                      Text,                                   nil => false, :default => ''
  #
  belongs_to    :dataset
  belongs_to    :contributor
end

class Tagging
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  has_handle
  has_time_and_user_stamps
  #
  property      :context,                       String,         :length      =>  40,    nil => false, :default => ''
  property      :tag_id,                        Integer
  property      :taggable_id,                   Integer
  property      :taggable_type,                 String,         :length      =>  40,    nil => false
  #
  property      :tagger_id,                     Integer
  property      :tagger_type,                   String,         :length      =>  40,    nil => false
  #
  belongs_to    :taggable, :class_name => 'Dataset', :child_key => [:taggable_id]
  belongs_to    :tag
  before :save, :fake_tagger_polymorphism; def fake_tagger_polymorphism() self.tagger_type = 'Contributor' end
end

class Tag
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 255,    nil => false, :default => ''
  has_handle                                                    :length      => 255
  has_time_and_user_stamps
  #
  has n,        :taggings
  has n,        :taggables, :through => :taggings
  has n,        :taggers,   :through => :taggings
end

class Link
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 512,    nil => false, :default => ''
  property      :full_url,                      Text,                                   nil => false, :default => ''
  has_handle
  has_time_and_user_stamps
  #
  property      :linkable_id,                   Integer
  property      :linkable_type,                 String,         :length      =>  40,    nil => false
  #
  property      :role,                          String,         :length      =>  40,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  #
  belongs_to    :linkable, :class_name => 'Dataset', :child_key => [:linkable_id],       :polymorphic  => true
  before :save, :fake_polymorphism; def fake_polymorphism() self.linkable_type = 'Dataset' end
end

class Note
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  property      :name,                          String,         :length      => 512,    nil => false, :default => ''
  has_handle
  has_time_and_user_stamps
  #
  property      :role,                          String,         :length      =>  40,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  #
  belongs_to    :noteable, :class_name => 'Dataset', :child_key => [:noteable_id],       :polymorphic  => true
  before :save, :fake_polymorphism; def fake_polymorphism() self.noteable_type = 'Dataset' end
end

class Rating
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  has_time_and_user_stamps
  #
  property      :user_id,                       Integer
  property      :rateable_id,                   Integer
  property      :rateable_type,                 String,         :length      =>  40,    nil => false
  #
  property      :rating,                        Integer,                                                    :default => 0
  property      :context,                       String,         :length      =>  40,    nil => false, :default => "overall"
  #
  belongs_to    :dataset,                                       :polymorphic  => true
  belongs_to    :rateable, :class_name => 'Dataset', :child_key => [:rateable_id],       :polymorphic  => true
  belongs_to    :user
  before :save, :fake_polymorphism; def fake_polymorphism() self.rateable_type = 'Dataset' end
end

class License
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  property      :name,                          String,         :length      => 512,    nil => false, :default => ''
  has_handle
  has_time_and_user_stamps
  #
  property      :url,                           String,         :length      => 255,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  #
  has n,        :license_infos
  has n,        :datasets,      :through => :license_infos
end

class LicenseInfo
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  has_time_and_user_stamps
  #
  property      :dataset_id,                    Integer
  property      :license_id,                    Integer
  #
  property      :url,                           String,         :length      => 255,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  #
  belongs_to    :license
  belongs_to    :dataset
end

class Payload
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  property      :file_name,                     String,         :length      => 150,    nil => false, :default => ''
  property      :file_path,                     String,         :length      => 2048,   nil => false, :default => ''
  has_handle
  has_time_and_user_stamps
  #
  property      :file_date,                     DateTime
  property      :format,                        String,         :length      => 40,     nil => false, :default => ''
  property      :shape,                         String
  property      :size,                          Integer
  property      :stats,                         Text
  #
  property      :signature,                     Text
  property      :signed_by,                     Integer
  property      :fingerprint,                   String,         :length      => 40,     nil => false, :default => ''
  #
  belongs_to    :dataset
end

class Field
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial => true
  has_time_and_user_stamps
  #
  property      :dataset_id,                    Integer
  property      :table_id,                      Integer
  #
  property      :name,                          String,         :length      => 150,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  property      :datatype,                      String,         :length      =>  40,    nil => false, :default => ''
  property      :representation,                String,         :length      => 255,    nil => false, :default => ''
  property      :concepts,                      String,         :length      => 255,    nil => false, :default => ''
  property      :constraints,                   String,         :length      => 255,    nil => false, :default => ''
  property      :stats,                         Text,                                   nil => false, :default => ''
  belongs_to    :dataset
end

class User
  include DataMapper::Resource
  include Infochimps::Resource
  property      :id,                            Integer,        :serial  => true
  property      :login,                         String,         :length  =>  40,        nil => false
  has_handle
  has_time_and_user_stamps
  #
  property      :prefs,                         String,         :length  => 2048
  #
  property      :identity_url,                  String,         :length  => 255,        nil => false, :unique      => true
  property      :name,                          String,         :length  => 100,        nil => false
  property      :email,                         String,         :length  => 100,        nil => false
  property      :email_is_public,               Boolean,                                              :default => false
  property      :homepage_link,                 String,         :length  => 255,        nil => false, :default     => ''
  property      :blurb,                         Text,           :length  => 255,        nil => false, :default     => ''
  #
  property      :public_key,                    Text
  property      :email_verification_code,       String,         :length  => 40
  property      :email_verified_at,             DateTime
  property      :roles,                         String,         :length  => 2048
end


# class Relationship
#
# end

