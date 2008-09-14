module Infochimps
  module Resource
    module ClassMethods
      def has_handle options = { }
        options = { :length => 255 }.merge options
        property      :handle,                      String,         :length      => options[:length], :nullable => false, :unique => true,     :unique_index => :handle
        cattr_accessor :class_uuid_namespace
        self.class_uuid_namespace = UUID.sha1_create(UUID_URL_NAMESPACE, "http://infochimps.org/#{self.to_s}")
        self.before    :create, :make_uuid_and_handle
        self.class_eval do
          def make_uuid_and_handle
            self.handle ||= self.handle_generator()
            self.uuid   ||= UUID.sha1_create(self.class.class_uuid_namespace, self.handle).hexdigest
          end
        end
      end
      def has_time_and_user_stamps
        include DataMapper::Timestamp
        property      :created_at,                  DateTime
        property      :updated_at,                  DateTime
        property      :created_by,                  Integer
        property      :updated_by,                  Integer
      end
    end
    def self.included base
      base.extend  ClassMethods
      # note -- exactly 32 chars long.
      base.property  :uuid,                          String,         :length      =>  32..32,         :nullable => false, :unique => true,     :unique_index => :uuid
    end
  end
end
