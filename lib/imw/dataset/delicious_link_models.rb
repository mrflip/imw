# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-ar-finders'
require 'dm-aggregates'
require 'imw/dataset/datamapper'
require 'imw/dataset/datamapper/uri'

#DataMapper::Logger.new(STDOUT, :debug)
IMW::DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_social_network_delicious' })

#
# Models for the delicious.com (formerly del.icio.us) social network
#
# Link:         has tags,   tagged by socialites
# Socialite:                describes links with tabs,  uses tags,         follows/followedby socialites
# Tag:          tags links,                             used by socialites

#
# First steps towards craws that can give an implied trust metric.
#   follow/follower graph
#   # follow/followers
#   # comments / posts / favorites / favorited
#   explicit karma
# sources:
#   Twitter
#   FriendFeed
#   Plurk (has explicit karma)
#   Twine
#   MetaFilter (also asked / answered numbers)
#   Ma.gnolia.com
#
class DeliciousLink
  include DataMapper::Resource
  # Basic info
  property      :id,                    Integer,  :serial => true
  property      :link_url,              String,   :length => 1024, :nullable => false
  property      :delicious_id,          String,   :length => 32,   :nullable => false,          :unique_index => true
  property      :num_delicious_savers,  Integer
  property      :title,                 String,   :length => 255
  has n,        :taggings
  has n,        :socialites_links
  has n,        :tags,          :through => :taggings
  has n,        :socialites,    :through => :socialites_links
end

class Tag
  include DataMapper::Resource
  property      :id,                    Integer,  :serial => true
  property      :name,                  String,   :length => 50,  :nullable => false,    :unique_index => :name
  has n,        :taggings
  has n,        :delicious_links,  :through => :taggings
  has n,        :socialites_tags
  has n,        :socialites,       :through => :socialites_tags
end

# http://delicious.com/ferrisp
class Socialite
  include DataMapper::Resource
  property   :id,                    Integer,   :serial => true
  property   :uniqname,              String,    :length => 100,  :nullable => false, :unique_index => :socialite_uniqname
  property   :following_count,       Integer
  property   :followers_count,       Integer
  property   :updates_count,         Integer
  # property :last_update_at,        DateTime
  # property :first_update_at,       DateTime
  # property :toptags,               Text # serialized top 10 tags
  property   :name,                  String,    :length => 40
  property   :description,           Text
  property   :bio_url,               String,    :length => 255
  #
  has n, :friendships,    :child_key => [:follower_id], :class_name => 'Friendship'
  has n, :followerships,  :child_key => [:friend_id],   :class_name => 'Friendship'
  has n, :taggings
  has n, :socialites_links
  has n, :socialites_tags
  has n, :tags,          :through => :socialites_tags
  has n, :links,         :through => :socialites_links
  # also has n, :tags    :through => :socialites_links but that's subsumed by :socialites_tags
end

#
# Relationships
#

class Tagging
  include DataMapper::Resource
  property    :tag_id,        Integer,                  :key => true
  property    :delicious_link_id, Integer,              :key => true
  property    :socialite_id,  Integer,                  :key => true
  belongs_to  :tag
  belongs_to  :socialite
  belongs_to  :delicious_link
end

class SocialitesTag
  include DataMapper::Resource
  property    :tag_id,        Integer,                  :key => true
  property    :socialite_id,  Integer,                  :key => true
  property    :tagged_count,  Integer
  belongs_to  :socialite
  belongs_to  :tag
end

class SocialitesLink
  include DataMapper::Resource
  property    :delicious_link_id, Integer,              :key => true
  property    :socialite_id,  Integer,                  :key => true
  property    :date_tagged,   DateTime
  property    :text,          String
  property    :description,   Text
  belongs_to  :socialite
  belongs_to  :delicious_link
end

class Friendship
  include DataMapper::Resource
  property    :follower_id,   Integer,                                  :key => true
  property    :friend_id,     Integer,                                  :key => true, :index => :friend_id
  belongs_to  :follower,      :class_name => 'Socialite',  :child_key => [:follower_id]
  belongs_to  :friend,        :class_name => 'Socialite',  :child_key => [:friend_id]
end

class RippedUrl
  include DataMapper::Resource
  include IMW_URI

  property      :id,              Integer,                           :serial   => true
  property      :ripd_url,        String,    :length => 1024
  property      :scheme,          String
  property      :user,            String
  property      :password,        String
  property      :host,            String,    :length => 128
  property      :port,            String        # note: port is not an integer: URI returns a string and it's almost always used as a string.
  property      :path,            Text
  property      :query,           Text
  property      :fragment,        Text

  property      :tried_parse,     Boolean,                        :default => false
  property      :did_parse,       Boolean,                        :default => false
  property      :ripd_file,       String,    :length => 1024
  property      :ripd_file_date,  DateTime
  property      :ripd_file_size,  Integer
  property      :rippable_type,   String,    :length =>  10,    :nullable => false, :index => :rippable_param,     :index => :rippable_user
  property      :rippable_param,  String,    :length => 255,                    :index => :rippable_param
  property      :rippable_user,   String,    :length =>  50,                    :index => :rippable_user
  property      :ripped_page,     Integer

  # ::off:: note: instance method
  def i_did_parse_joo!
    self.did_parse = true
    self.save
    self
  end

  # FIXME -- make it before_save; denormalize.
  def set_rippable_info_from_url!
    # pull page from query string
    _, page = %r{page=(\d+)}.match(self.query).to_a
    page ||= 1
    # pull type, param from path
    _, type, param = %r{^/([^/]+)(?:/(.*?))?$}.match(self.path).to_a
    case
    when ['tag', 'url'].include?(type)  then type, user, param = [type,       nil,  param]
    when ['search'].include?(type)      then type, user, param = [type,       nil,  self.query]
    when param.blank?                   then type, user, param = ['user',     type, nil]
    else                                     type, user, param = ['user_tag', type, param] end
    # save grokked result
    self.rippable_type, self.rippable_param, self.rippable_user, self.ripped_page = [type, param, user, page]
    self.save
    self
  end

  # ::off:: note: class method
  def self.i_parse_joo! ripd_file, ripd_url=nil
    ripd_url ||= 'http://'+ripd_file
    ripd = self.find_or_create_from_url(ripd_url)

    ripd.attributes = { :ripd_url => ripd_url,
      :ripd_file => ripd_file,
      :ripd_file_size => File.size( ripd_file),
      :ripd_file_date => File.mtime(ripd_file) }
    ripd.set_rippable_info_from_url!
    ripd.save
    ripd
  end

  def description
    case self.rippable_type
    when 'tag', 'url', 'search' then "page %3d for %-4s %s"        % [self.ripped_page, self.rippable_type+':',  self.rippable_param]
    when 'user'                 then "page %3d for %-4s %s"        % [self.ripped_page, self.rippable_type,      self.rippable_user]
    when 'user_tag'             then "page %3d for user %-20s tag %s" % [self.ripped_page, self.rippable_user+"'s", self.rippable_param]
    else
      self.to_s
    end
  end

end
