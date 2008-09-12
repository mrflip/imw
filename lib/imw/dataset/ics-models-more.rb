require 'ics-models'


# Non-dataset site models, in case that's ever interesting

class Search
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :uniqname,                      String,        :length      => 40,         nil          => false
  property      :freetext,                      String,        :length      => 255
  property      :name,                          String,        :length      => 255
  property      :tags,                          String,        :length      => 255
  property      :category,                      String,        :length      => 64
  property      :rating_min,                    Integer,       :default     => nil
  property      :rating_max,                    Integer,       :default     => nil
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime

end

class Info
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :name,                          String
  property      :uniqname,                      String,        :length      => 40,         nil          => false
  property      :desc,                          Text
end

class Talk
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :dataset_id,                    Integer
  property      :topic,                         String
  property      :desc,                          Text
  property      :user_id,                       Integer
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  belongs_to    :dataset
end
