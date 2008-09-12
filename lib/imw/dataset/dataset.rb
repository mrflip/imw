module IMW
  class Dataset
    #===============================================================================
    #
    # Macros
    #
    slug_on       :name


    #===============================================================================
    #
    # Methods
    #
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
        self.rights_statement = RightsStatement.create(:license => License.find_by_handle(:needs_rights))
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

end
