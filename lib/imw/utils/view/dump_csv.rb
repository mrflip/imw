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
class IMWObject

  def self.from_icss(hsh)
    # lists of dumpables
    self._attr_objlists.each do |attr, cl|
      if (vals = hsh.delete(attr.to_s))
        hsh[attr] = vals.map{ |val| cl.from_icss(val) }
      end
    end
    # simply dumpable objects
    self._attr_objs.each do |attr, cl|
      if (val = hsh.delete(attr.to_s))
        hsh[attr] = cl.from_icss(val)
      end
    end
    self.new(hsh)
  end

  # Dump as a plain hash
  def to_icss()
    hsh = instance_values
    # lists of dumpable objects
    self.class._attr_objlists.keys.map(&:to_s).each do |attr|
      hsh[attr] = (hsh.delete(attr)||[]).map{ |a| a.to_icss() }
    end
    # simply dumpable objects
    self.class._attr_objs.keys.map(&:to_s).each do |attr|
      (v=hsh.delete attr) && hsh[attr] = v.to_icss
    end
    hsh
  end

  # Pivot from object to relational view
  def to_csv(parent_id=nil)
    tables   = {}
    sub_ids  = []
    my_cl    = self.class.to_s
    self.class._attr_objs.sort.each do |attr, cl|
      tables[attr] ||= [] ; tables[attr].push(self[attr].to_csv(id))
      join = "%s_%s" % [my_cl, cl.to_s].sort
      tables[join] ||= [] ; tables[join].push(id, self[attr].id)
      sub_ids.push self[attr].handle
    end

    self.class._attr_objlists.sort.each do |attr, cl|
      tables[attr] ||= []
      join = "%s_%s" % [my_cl, cl.to_s].sort
      tables[join] ||= []
      self[attr].each do |obj|
        tables[attr].push(obj.to_csv(id))
        tables[join].push(id, obj.id)
        sub_ids.push obj.handle
      end
    end


    tables[self.class.to_s] = [
      [self.id, parent_id].compact   +
      slice(self.class._attr_scalars.keys - [:id]) +
      sub_ids
    ]
    tables
  end

end

class Note  < IMWObject
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



# You acquire the vision of a sharp-eyed tanzier.  We'll just assume that's good.
