class Dataset
  include DataMapper::Resource
  include Infochimps::Resource
  # Identity
  property      :id,                            Integer,        :serial      => true
  property      :name,                          String,         :length      => 255,          :nullable => false, :default => ''
  has_handle
  alias_method  :handle_generator, :name
  has_time_and_user_stamps
  #
  property      :category,                      String,         :length      =>  50,          :nullable => false, :default => ''
  property      :collection_id,                 Integer
  property      :is_collection,                 Boolean,        :default     => false
  #
  property      :valuation,                     Text,           :default     => "{}"
  property      :metastats,                     Text,           :default     => "{}"
  property      :facts,                         String,         :default     => "{}"
  property      :delicious_taggings,            Integer
  property      :base_trust,                    Integer
  property      :trust_value,                   Integer,                                :index => :trust_value
  property      :num_delicious_savers,          Integer,                                :index => :num_delicious_savers
  property      :skip_me,                       Boolean
  #
  has n,        :credits
  has n,        :contributors, :through     => :credits
  has n,        :notes,                                     :child_key   => [:noteable_id]
  has n,        :payloads
  has n,        :ratings,                                   :child_key   => [:rateable_id]
  has 1,        :license_info
  has 1,        :license,     :through     => :license_info
  has n,        :taggings,                                  :child_key => [:taggable_id]
  has n,        :tags,        :through => :taggings,        :child_key => [:taggable_id]
  has n,        :taggers,     :through => :taggings,        :child_key => [:taggable_id], :class_name => 'Contributor'
  has n,        :linkings,                                  :child_key => [:linkable_id]
  has n,        :links,       :through => :linkings,        :child_key => [:linkable_id]

  #===============================================================================
  #
  # Macros
  #
  # slug_on       :name
  # before :save, :force_approval
  # before :save, :insert_default_rights_statement
  # before :save, :insert_default_link

  #===============================================================================
  #
  # Methods
  #
  def description
    @description ||= self.notes.first({ :role => 'description' })
  end
  def set_note(role, text, name)
    a_note = self.notes.find_or_create({ :role => role, :noteable_id => self.id })
    self.notes << a_note
    a_note.name = name
    a_note.desc = text
    a_note.save
    a_note
  end
  def description=(text)
    @description = self.notes.find_or_create({ :role => 'description', :noteable_id => self.id })
    self.notes << @description
    @description.desc = text
    @description.save
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

  def force_approval
    [:approved_by, :created_by, :updated_by,].each do |actor|
      self.send("#{actor}=", User.find_by_login('flip').id)
    end
    self.approved_at ||= Time.now
  end

  def insert_default_rights_statement
    if !self.rights_statement
      self.rights_statement = RightsStatement.create(:license => License.find_by_handle(:needs_rights))
    end
  end

  def insert_default_link
    if links.empty?
      l = links.find_or_create({:role => :main}, :full_url => url, :name => description.desc)
      links << l
    end
  end

  attr_accessor :fact_hash
  def fact_hash
    @fact_hash ||= self.facts.blank? ? { } : YAML.load(self.facts)
  end
  before :save, :serialize_facts
  def serialize_facts
    self.facts = @fact_hash.to_yaml if @fact_hash
  end

  def set_fact attr, key, val
    self.fact_hash[key] = val
  end
end
