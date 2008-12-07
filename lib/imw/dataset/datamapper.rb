require 'rubygems'
require 'dm-core'
require 'dm-ar-finders'
require 'dm-aggregates'
require 'dm-serializer'


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
    DataMapper.setup(options[:handle], "%s://%s/%s" % params)
  end

  # KLUDGE
  def self.open_repositories repository_dbnames, params
    repository_dbnames.each do |handle, dbname|
      repo_params = params.merge({ :handle => handle, :dbname => dbname })
      DataMapper.setup_remote_connection repo_params
    end
  end


  module Model
    # find or creat the resource matching search attributes
    # and in either case set the updateable attributes
    def update_or_create(search_attributes, updateable_attributes = {})
      if (resource = first(search_attributes))
        resource.update_attributes updateable_attributes
      else
        resource = create(search_attributes.merge(updateable_attributes))
      end
      resource
    end
  end

  # watch SQL log -- must be BEFORE call to db setup
  def self.logging=(verbosity)
    verbosity = :debug if (verbosity == true)
    DataMapper::Logger.new(STDERR, verbosity) if verbosity
  end
end
