#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/.'
require 'rubygems'
require 'imw'; include IMW
require 'imw/dataset'
require 'fileutils'; include FileUtils

DataMapper::Logger.new(STDOUT, :debug)
# Dataset.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_ics_scaffold' })
Dataset.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS


# #
# # Wipe DB and add new migration
# #
# DataMapper.auto_migrate!
# Contributor,
# [Dataset, Credit, Tagging, Tag, Field, Link, Note, Payload, Rating, License, LicenseInfo, User].each do |klass|
#   puts klass.to_s
#   klass.auto_migrate!
# end

Dataset.auto_migrate!

# Destroy old
announce "Destroying old"

# Info, Search, Talk,
#[Contributor, Credit, Dataset, Tagging, Tag, Field, Link, Note, Payload, Rating, RightsStatement, License, User].each do |klass|
#   klass.all.each{ |l| l.destroy }
# end


# raise "Skipped! Uncomment!"


