#
# A struct
# but has an idea of what type attributes should be
#
#
class TypedStruct < Struct
  def self.new attrs, convs
    struct = super *attrs
    struct_attr_convs = Hash.zip(attrs, convs).reject{|a,t| t.nil? }
    struct.class_eval do
      cattr_accessor :attr_convs
      self.attr_convs = struct_attr_convs
      def remap!
        attr_convs.each do |attr, conv|
          curr = self.send(attr)
          self.send("#{attr}=", curr.send(conv)) if curr.respond_to?(conv)
        end
      end
    end # class_eval
    struct
  end
end
