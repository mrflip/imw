
#
# A somewhat-structured class type
#
class IMWStruct
  class << self ; attr_accessor(:_attr_class, :_attr_scalar, :_attr_has_one, :_attr_has_many, :_attr_has_abtm) ; end
  @_attr_class    = { }
  @_attr_scalar   = []  # simple scalar values
  @_attr_has_one  = []  # has_one
  @_attr_has_many = []  # has_many
  @_attr_has_abtm = []  # has_and_belongs_to_many
  def self._attrs()     @_attr_scalar + @_attr_has_one + @_attr_has_many + @_attr_has_abtm end
  def self._attr_manys() (_attr_has_many + _attr_has_abtm).map(&:to_s)  end
  # Nominal class of that attribute
  def self.get_attr_class(attr)
    self._attr_class[attr.intern]
  end

  def self.inherited(subclass)
    subclass.instance_variable_set("@_attr_class",    @_attr_class.clone   )
    subclass.instance_variable_set("@_attr_scalar",   @_attr_scalar.clone  )
    subclass.instance_variable_set("@_attr_has_one",  @_attr_has_one.clone )
    subclass.instance_variable_set("@_attr_has_many", @_attr_has_many.clone)
    subclass.instance_variable_set("@_attr_has_abtm", @_attr_has_abtm.clone)
  end

  #
  # Defines an inherited attribute, to have a given nominal class
  # and (optionally) to be treated as a structured object in its
  # own right.
  #
  def self.with_attr(attr, cl, rel=:scalar)
    @_attr_class[attr] = cl
    case rel
      when :scalar     then @_attr_scalar   << attr
      when :belongs_to then @_attr_scalar   << attr  # foreign key
      when :has_one    then @_attr_has_one  << attr
      when :has_many   then @_attr_has_many << attr
      when :has_abtm   then @_attr_has_abtm << attr
      when :has_and_belongs_to_many then self._attr_has_abtm << attr
    end
    attr_accessor attr
  end

  #
  # Adopt the parameters from the hash
  # as instance variables
  #
  def initialize(hsh)
    self.merge!(hsh)
    @id = identify(self)
  end

  # Adopt the hash key=>values as attributes
  # warn (and do not take) extra values.
  def merge!(hsh)
    hsh.each do |key,val|
      if   respond_to?(key.to_s + '=')
      then instance_variable_set( "@#{key}".intern, val )
      else warn "Spurious attribute #{key}: #{val}" end
    end
  end

  @@_id_maxlen = $imw_id_maxlen
  # Turn an object's name into an identifier
  def identifierize(nm)
    nm = nm.to_s.underscore
    nm.gsub!(/\[[^\]]+\]/,'')  # Kill off stuff in square brackets
    nm.gsub(/\A[\W_]+/,'').gsub(/[\W_]+\Z/,'').gsub(/[\W_]+/, '_')[0..@@_id_maxlen]
  end
  # if no handle, fabricate one from the name
  def fix_handle!(schema)
    schema['handle'] ||= underscore(schema['name'])
  end

  def [](el)
    instance_variable_get("@#{el}".intern)
  end

  #
  # get the
  def slice(attrs)
    attrs.map{ |a| self[a] }
  end

  @@ids = {}
  def identify(obj)
    kind = obj.class.to_s.intern
    @@ids[kind] ||= {}
    @@ids[kind][obj.handle] ||= @@ids[kind].length
  end
  def self.ids() @@ids end
end
