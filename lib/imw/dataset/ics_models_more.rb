# Non-dataset site models, in case that's ever interesting

class Search
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :handle,                      String,        :length      => 40,         nil          => false
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :freetext,                      String,        :length      => 255
  property      :name,                          String,        :length      => 255
  property      :tags,                          String,        :length      => 255
  property      :category,                      String,        :length      => 64
  property      :rating_min,                    Integer,       :default     => nil
  property      :rating_max,                    Integer,       :default     => nil
end

class Info
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :handle,                        String,        :length      => 40,        :nullable  => false
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :name,                          String
  property      :desc,                          Text
end

class Talk
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :dataset_id,                    Integer
  property      :topic,                         String
  property      :desc,                          Text
  property      :user_id,                       Integer
  #
  belongs_to    :dataset
end

class OpenIDAuthenticationAssociation
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :issued,                        Integer
  property      :lifetime,                      Integer
  property      :handle,                        String
  property      :assoc_type,                    String
  property      :server_url,                    Text
  property      :secret,                        Text
end

class OpenIDAuthenticationNonce
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :timestamp,                     Integer,        :nullable  => false
  property      :server_url,                    String,         :nullable  => false
  property      :salt,                          String,         :nullable  => false
end
