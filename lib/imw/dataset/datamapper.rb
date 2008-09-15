require 'rubygems'
require 'dm-core'
require 'dm-ar-finders'
require 'dm-aggregates'
# require 'dm-timestamps'

module DataMapper
  # Connect to a remote database
  def self.setup_remote_connection options
    options = { :handle => :default }.merge options
    params = options.values_at(:protocol, :username, :password, :hostname, :dbname)
    DataMapper.setup(options[:handle], "%s://%s:%s@%s/%s" % params)
  end
  # Connect to a local database
  def self.setup_local_connection options
    options = { :handle => :default }.merge options
    params = options.values_at(:protocol, :dbpath, :dbname)
    DataMapper.setup(options[:handle], "%s://%s/%s" % options)
  end

  # KLUDGE
  def open_repositories repository_dbnames, params
    repository_dbnames.each do |handle, dbname|
      repo_params = params.merge({ :handle => handle, :dbname => dbname })
      DataMapper.setup_remote_connection repo_params
    end
  end
end
