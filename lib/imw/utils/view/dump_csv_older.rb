# #
# # views
# #
# require 'imw/view/db_infochimps'
#


#
# This is where views of the metadata will go (right now it's all just
# sitting in a crapheap within model.rb).
#
# we'll have routines for
#
# - dumping/undumping to yaml
# - dumping/undumping to files that load right into the ics database.
#
class IMWBase

  def self.from_icss(hsh)
    # simply dumpable objects
    self._attr_has_one.map(&:to_s).each do |attr|
      if (val = hsh.delete(attr.to_s))
        hsh[attr] = get_attr_class(attr).from_icss(val)
      end
    end
    # lists of dumpables
    self._attr_manys.each do |attr|
      if (vals = hsh.delete(attr.to_s))
        hsh[attr] = vals.map{ |val| get_attr_class(attr).from_icss(val) }
      end
    end
    self.new(hsh)
  end

  # Dump as a plain hash
  def to_icss()
    hsh = instance_values
    # simply dumpable objects
    self.class._attr_has_one.map(&:to_s).each do |attr|
      (v=hsh.delete attr) && hsh[attr] = v.to_icss
    end
    # lists of dumpable objects
    self.class._attr_manys.each do |attr|
      hsh[attr] = (hsh.delete(attr)||[]).map{ |a| a.to_icss() }
    end
    hsh
  end

  # Pivot from object to relational view
  def to_csv(parent_id=nil)
    tables   = {}
    sub_ids  = []
    my_cl    = self.class.to_s
    self.class._attr_has_one.map(&:to_s).sort.each do |attr|
      # Banks the object
      obj = self[attr]
      cl  = self.class.get_attr_class(attr).to_s
      tables[attr] ||= [] ; tables[attr].push( obj.to_csv(id) )
      # tie the parent and child together
      join = "%s_%s" % [my_cl, cl].sort
      tables[join] ||= [] ; tables[join].push( [id, obj.id] )
      sub_ids.push obj.handle
    end

    self.class._attr_manys.sort.each do |attr|
      objs = self[attr] or next
      cl   = self.class.get_attr_class(attr).to_s
      tables[attr] ||= []
      join = "%s_%s" % [my_cl, cl.to_s].sort
      tables[join] ||= []
      objs.each do |obj|
        tables[attr].push(obj.to_csv(id))
        tables[join].push(id, obj.id)
        sub_ids.push obj.handle
      end
    end


    tables[self.class.to_s] = [
      [self.id, parent_id].compact   +
      slice(self.class._attr_scalar - [:id]) +
      sub_ids
    ].zip(['id', 'pid']+(self.class._attr_scalar - [:id])+self.class._attr_has_one.map(&:to_s).sort)
    tables
  end

end

class Note  < IMWBase
  # { :format_name => {}, ... } -- must be a hash
  def to_pair()
    { self.handle => self.desc }
  end
  def to_icss()
    to_pair
  end
  def self.from_icss(pair)
    self.new Hash.zip([:handle,:desc], pair.to_pair)
  end
end


class TagList
  def self.from_icss(str)
    self.from(str)
  end
  def to_icss()
    self.to_s
  end
  def to_csv(parent_id=nil)
    [self.to_s]
  end

  def handle() to_s end
end


