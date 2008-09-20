
class ActiveRecord::Base
  class << self
  end
  # def merge!(hsh)
  #   hsh = hsh.dup
  #   # puts hsh.to_yaml
  #   # has_many datasets, notes, fields, contributors
  #   self.class.reflect_on_all_associations.each do |ass|
  #     # ["@macro", "@class_name", "@name", "@primary_key_name", "@options",
  #     #  "@klass",
  #     #  "@through_reflection",
  #     #  "@active_record",
  #     puts [ass.name, ass.macro, ass.primary_key_name].to_yaml
  #     if ass.macro == :has_many
  #       els = hsh.delete(ass.name.to_s) || []
  #       puts "!!!!!!!!!!!!!!!!!!!!!!!!!!", els, '!!'
  #       els.each do |el|
  #         puts el
  #         self[ass.name] = ass.klass.new().merge!(el)
  #       end
  #     end
  #     hsh.each do |key,val|
  #       self[key] = val
  #     end
  #     p self
  #     p self.datasets if self.respond_to? 'datasets'
  #   end
  # end
  def undump(hsh)
    puts "unumping from #{hsh.to_json}"
    hsh.each{ |k,v| self[k] = v }
    self.save!
    self
  end
end

class Pool < ActiveRecord::Base
  def undump(hsh)
    { :datasets => Dataset, :fields => Field,
      :contributors => Contributor, :pool_notes => PoolNote }.each do |field, klass|
      vals = hsh.delete(field.to_s) || []
      puts "Undumping #{vals} info #{field}"
      self[field.to_s] = vals.map{|val| f = klass.new().undump(val); f.save!; f}
    end
    super
    self
  end
end

class Dataset < ActiveRecord::Base
  def undump(hsh)
    { :datasets => Dataset, :fields => Field,
      :contributors => Contributor, :dataset_notes => DatasetNote }.each do |field, klass|
      vals = hsh.delete(field.to_s) || []
      puts "Undumping #{vals} info #{field}"
      self[field.to_s] = vals.map{|val| f = klass.new().undump(val); f.save!; f}
    end
    super
    puts "Got Dataset #{self.to_yaml}"
    self
  end
end

class IMW < OpenStruct

  #
  # Takes an Infochimps Stupid Schema stream and
  # constructs the corresponding objects.
  #
  # Here are the rules:
  # * the schema has the structure
  #   # this has to be first.
  #   - infochimps_schema:
  #       schema_version:     0.2  # in case stuff changes
  #   # then any number of imw objects:
  #   - pool:         (...)
  #       fields:         [era, innings_pitched,
  #   - dataset:      (...)
  #       fields:
  #         - name:       Earned Run Average
  #           handle:   era
  #           concept:    baseball-era
  #           units:      earned_runs / (9*innings_pitched)
  #   - contributor:  (...)
  #   - field:        (...)
  #
  # * Objects are referred to by __handle__, *NOT* __id__. If an ID is
  #   included, and an object exists with a non-matching ID or handle,
  #   an error will be raised.
  #
  # * We want to make the schema files maintainable by hand, which means that
  #   the loader tries to be smart about inline-defined objects.  That is, you
  #   can either refer to (via handle) a field defined elsewhere, or you can
  #   define the field in whole, and trust that the Right Thing will
  #   happen. This presents the problem of collisions, though. If a bulk object
  #   update arrives, we need to know whom to believe -- bulk loader or
  #   database.  In the absence of versioning: we look up the object by its
  #   handle.  If there's an existing object, any new information (fields with
  #   values in new that are blank in old) is added to it.  If the object is
  #   defined at the top level, it wins; if the object is defined as a sub field
  #   it loses.
  #
  # * Every interesting object (Pool, Dataset, Contributor, Field) has a desc:
  #   attribute (for Pool and Dataset it's virtual but never mind) to describe
  #   __itself__.  Additionally, every interesting relationship has its own desc: field.
  #

  def self.undump(schema)

    # compact then merge -- kill off blank
  end
end
