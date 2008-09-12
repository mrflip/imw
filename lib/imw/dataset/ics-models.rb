# -*- coding: utf-8 -*-
require 'rubygems'
require 'imw'; include IMW; IMW.verbose = true
require 'imw/dataset/datamapper'
require 'dm-ar-finders'
require 'dm-aggregates'
require 'dm-timestamps'
require 'slug'

#DataMapper::Logger.new(STDOUT, :debug)
# DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_ics_scaffold' })
DataSet.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS

#
# Datamapper interface to infochimps
#

class Dataset
  include DataMapper::Resource
  include Sluggable;
  slug_on :name
  property      :id,                            Integer,        :serial => true
  property      :approved_at,                   DateTime
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :approved_by,                   Integer
  property      :created_by,                    Integer
  property      :updated_by,                    Integer
  #
  property      :name,                          String,         :length      => 255,          nil          => false, :default => ''
  property      :uniqname,                      String,         :length      => 255,          nil          => false
  property      :category,                      String,         :length      =>  40,          nil          => false, :default => ''
  property      :url,                           String,         :length      => 255,          nil          => false, :default => ''
  property      :collection_id,                 Integer
  property      :is_collection,                 Boolean,        :default     => false
  property      :valuation,                     String,         :default     => "{}"
  property      :num_downloads,                 Integer,        :default     =>  0
  #
  has n,        :credits
  has n,        :contributors,          :through     => :credits
  has n,        :notes,                 :child_key   => [:noteable_id]
  has n,        :links,                 :child_key   => [:linkable_id]
  has n,        :payloads
  has n,        :ratings,               :child_key   => [:rateable_id]
  has 1,        :rights_statement
  has 1,        :license,               :through     => :rights_statement
  has n,        :taggings,              :child_key => [:taggable_id]
  has n,        :tags,                  :through => :taggings,  :child_key => [:taggable_id]

  def description
    @description ||= self.notes.first({ :role => 'description' })
  end
  def description=(text)
    @description = self.notes.find_or_create({ :role => 'description' })
    self.notes << @description
    @description.desc = text
  end
  # tags are ',' separated
  def tag_with(context, tags_list)
    return if tags_list.blank?
    tag_strs = tags_list.split(',').map{|s| s.gsub(/[^\w]+/,'') }.reject(&:blank?)
    tag_strs.each do |tag_str|
      tag     = Tag.find_or_create({ :name => tag_str })
      tagging = Tagging.find_or_create({ :tag_id => tag.id, :context => context, :taggable_id => self.id, :taggable_type => self.class.to_s })
    end if tag_strs
  end
  # adds a note with _context (hiding it from normal view)
  #
  def add_internal_note context, info
    note = internal_note context
    note.desc = info.to_yaml
    note.save
  end
  def internal_note context
    note = self.notes.find_or_create( :role => "_#{context}" )
    self.notes << note
    note
  end
  def register_info key, val
    note = internal_note(:info)
    info = YAML.load(note.desc) || {}
    (info[key]||=[]) << val
    info[key].uniq!
    note.desc = info.to_yaml
    note.save
    note
  end
  def credit contributor, attrs
    self.credits << self.credits.find_or_create({ :contributor_id => contributor.id, }, attrs)
  end

  before :save, :force_approval
  def force_approval
    [:approved_by, :created_by, :updated_by,].each do |actor|
      self.send("#{actor}=", User.find_by_login('flip').id)
    end
    self.approved_at ||= Time.now
  end


  before :save, :insert_default_rights_statement
  def insert_default_rights_statement
    if !self.rights_statement
      self.rights_statement = RightsStatement.create(:license => License.find_by_uniqname(:needs_rights))
    end
  end

  before :save, :insert_default_link
  def insert_default_link
    if links.empty?
      l = links.find_or_create({:role => :main}, :full_url => url, :name => description.desc)
      links << l
    end
  end


end


class Contributor
  include DataMapper::Resource
  include Sluggable

  self.slug_on :url
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :uniqname,                      String,         :length      => 255,    nil => false
  #
  property      :url,                           String,         :length      => 255,    nil => false, :default => ''
  property      :name,                          String,         :length      => 150,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  property      :base_trustification,           Integer,                                              :default => 0
  #
  has n,        :credits
  has n,        :datasets,  :through     => :credits
end

class Credit
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
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
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :tag_id,                        Integer
  property      :taggable_id,                   Integer
  property      :taggable_type,                 String,         :length      =>  40,    nil => false
  property      :tagger_id,                     Integer
  property      :tagger_type,                   String,         :length      =>  40,    nil => false
  before :save, :fake_tagger_polymorphism; def fake_tagger_polymorphism() self.tagger_type = 'User' end
  #
  property      :context,                       String,         :length      =>  40,    nil => false, :default => ''
  belongs_to    :taggable, :class_name => 'Dataset', :child_key => [:taggable_id]
  belongs_to    :tag
end

class Tag
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :name,                          String,         :length      => 255,    nil => false, :default => ''
  has n,        :taggings
  has n,        :taggables, :through => :taggings
end

class Link
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :linkable_id,                   Integer
  property      :linkable_type,                 String,         :length      =>  40,    nil => false
  before :save, :fake_polymorphism; def fake_polymorphism() self.linkable_type = 'Dataset' end
  #
  property      :full_url,                      Text,                                   nil => false, :default => ''
  property      :role,                          String,         :length      =>  40,    nil => false, :default => ''
  property      :name,                          String,         :length      => 150,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  belongs_to    :linkable, :class_name => 'Dataset', :child_key => [:linkable_id],       :polymorphic  => true

  # Delegate methods to uri
  def uri
    @uri ||= Addressable::URI.heuristic_parse(self.full_url).normalize
  end
  # Dispatch anything else to the aggregated uri object
  def method_missing method, *args
    if self.uri.respond_to?(method)
      self.uri.send(method, *args)
    else
      super method, *args
    end
  end

  #
  # The standard file path for this url's ripped cache
  #
  def ripd_file
    return @ripd_file if @ripd_file
    @ripd_file = File.join(host, path).gsub(%r{/+$},'') # kill terminal '/'
    @ripd_file = File.join(@ripd_file, 'index.html') if File.directory?(@ripd_file)
    @ripd_file
  end

  # 866 997 3688
  # 363659

  def wget options={}
    options = {
      :root       => path_to(:ripd_root),
      :wait       => 2,
      :noretry    => true,
      :noisy      => true,
      :clobber    => false,
    }.merge(options)
    cd path_to(options[:root]) do
      if (not options[:clobber]) && File.file?(ripd_file) then
        puts "Skipping #{ripd_file}" if options[:noisy]; return
      end
      # Do the fetch
      cmd = %Q{wget -nv "#{full_url}" -O"#{ripd_file}"}
      puts cmd if options[:noisy]
      print `#{cmd}`
      success = File.exists?(ripd_file)
      if !success && options[:noretry]
        puts "wget failed; leaving a turd in #{ripd_file}"
        FileUtils.mkdir_p File.dirname(ripd_file)
        FileUtils.touch ripd_file
      end
      # Sleep for a bit -- no hammer.
      sleep options[:wait]
      return success
    end
  end
end

class Note
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :noteable_id,                   Integer
  property      :noteable_type,                 String,         :length      =>  40,    nil => false
  before :save, :fake_polymorphism; def fake_polymorphism() self.noteable_type = 'Dataset' end
  #
  property      :role,                          String,         :length      =>  40,    nil => false, :default => ''
  property      :name,                          String,         :length      => 150,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  belongs_to    :noteable, :class_name => 'Dataset', :child_key => [:noteable_id],       :polymorphic  => true
end

class Rating
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :user_id,                       Integer
  property      :rateable_id,                   Integer
  property      :rateable_type,                 String,         :length      =>  40,    nil => false
  before :save, :fake_polymorphism; def fake_polymorphism() self.rateable_type = 'Dataset' end
  #
  property      :rating,                        Integer,                                                    :default => 0
  property      :context,                       String,         :length      =>  40,    nil => false, :default => "overall"
  belongs_to    :dataset,                                    :polymorphic  => true
  belongs_to    :rateable, :class_name => 'Dataset', :child_key => [:rateable_id],       :polymorphic  => true
  belongs_to    :user
end

class License
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :name,                          String,         :length      => 150,    nil => false, :default => ''
  property      :uniqname,                      String,         :length      => 150,    nil => false
  property      :url,                           String,         :length      => 255,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  has n,        :rights_statements
  has n,        :datasets,      :through => :rights_statements
end

class RightsStatement
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :dataset_id,                    Integer
  property      :license_id,                    Integer
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :name,                          String,         :length      => 150,    nil => false, :default => ''
  property      :url,                           String,         :length      => 255,    nil => false, :default => ''
  property      :desc,                          Text,                                   nil => false, :default => ''
  belongs_to    :license
  belongs_to    :dataset
end

class Payload
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :dataset_id,                    Integer
  property      :uploaded_by,                   Integer
  #
  property      :file_name,                     String,         :length      => 150,    nil => false, :default => ''
  property      :file_path,                     String,         :length      => 2048,   nil => false, :default => ''
  property      :file_date,                     DateTime
  property      :format,                        String,         :length      => 40,     nil => false, :default => ''
  property      :shape,                         String
  property      :size,                          Integer
  property      :stats,                         Text
  property      :signature,                     Text
  property      :signed_by,                     Integer
  property      :fingerprint,                   String,         :length      => 40,     nil => false, :default => ''
  belongs_to    :dataset
end

class Field
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
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
  property      :id,                            Integer,        :serial  => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :prefs,                         String,         :length  => 2048
  property      :info_edited_at,                DateTime
  #
  property      :login,                         String,         :length  =>  40,        nil => false
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
