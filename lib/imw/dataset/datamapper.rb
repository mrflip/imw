require 'rubygems'
require 'imw/dataset'
require 'dm-core'
require 'dm-ar-finders'
require 'dm-aggregates'

module IMW
  class DataSet
    # Connect to a remote database
    def self.setup_remote_connection options
      params = options.values_at(:protocol, :username, :password, :hostname, :dbname)
      DataMapper.setup(:default, "%s://%s:%s@%s/%s" % params)
    end
    # Connect to a local database
    def self.setup_local_connection options
      params = options.values_at(:protocol, :dbpath, :dbname)
      DataMapper.setup(:default, "%s://%s/%s" % options)
    end
  end
end
