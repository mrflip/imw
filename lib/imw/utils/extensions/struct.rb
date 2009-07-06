Struct.class_eval do
  def slice *attrs
    hsh = {}
    attrs.each{|attr| hsh[attr] = self.send(attr) }
    hsh
  end

  def to_hash
    slice(*self.class.members)
  end
  def self.from_hash(hsh)
    self.new *hsh.values_at(*self.members.map(&:to_sym))
  end


  #
  # values_at like a hash
  #
  def values_of *attrs
    slice(*attrs).values_at(*attrs)
  end
  def each_pair *args, &block
    self.to_hash.each_pair(*args, &block)
  end

  def merge *args
    self.dup.merge! *args
  end
  def merge! hsh, &block
    raise "can't handle block arg yet" if block
    hsh.each_pair{|key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
    self
  end
  alias_method :update, :merge!
  def indifferent_merge  *args, &block
    self.dup.indifferent_merge! *args
  end
  def indifferent_merge! hashlike, &block
    merge! hashlike.reject{|k,v| ! self.members.include?(k.to_s) }
  end
end
