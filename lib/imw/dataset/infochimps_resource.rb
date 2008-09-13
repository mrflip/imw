
module Infochimps
  module Resource
    module ClassMethods
      def has_handle options = { }
        options = { :length => 255 }.merge options
        property      :handle,                      String,         :length      => options[:length], :nullable => false, :unique => true,     :unique_index => :handle
      end
      def has_time_and_user_stamps
        include DataMapper::Timestamp
        property      :created_at,                  DateTime
        property      :updated_at,                  DateTime
        property      :created_by,                  String,         :length      => 90
        property      :updated_by,                  String,         :length      => 90
      end
    end
    def self.included base
      base.extend  ClassMethods
      # note -- exactly 32 chars long.
      base.property  :uuid,                          String,         :length      =>  32..32,         :nullable => false, :unique => true,     :unique_index => :uuid
    end
  end
end
