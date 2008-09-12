#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/.'
require 'rubygems'
require 'imw'
require 'imw/dataset'; include IMW
require 'imw/dataset/datamapper'
require 'fileutils'; include FileUtils

#DataMapper::Logger.new(STDOUT, :debug)
# DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_ics_scaffold' })
DataSet.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS


# #
# # Wipe DB and add new migration
# #
DataMapper.auto_migrate!


# Destroy old
announce "Destroying old"
# Info, Search, Talk,
# [Contributor, Credit, Dataset, Tagging, Tag, Field, Link, Note, Payload, Rating, RightsStatement, License, User].each do |klass|
#   klass.all.each{ |l| l.destroy }
# end


# raise "Skipped! Uncomment!"


