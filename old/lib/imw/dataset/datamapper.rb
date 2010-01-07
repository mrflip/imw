#
# h2. lib/imw/dataset/datamapper.rb -- extensions to datamapper for datasets
#
# == About
#
# The DataMapper[http://datamapper.org/] library is an ORM for Ruby
# which is lighter than ActiveRecord[http://ar.rubyonrails.com/] and
# the like.  It is the ORM that IMW is designed to work natively with.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/utils'
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
    
    # Find or create the resource matching search attributes and in
    # either case set the update-able attributes.
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
