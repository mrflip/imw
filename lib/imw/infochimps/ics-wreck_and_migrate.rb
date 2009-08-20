#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/.'
require 'rubygems'
require 'imw'; include IMW
require 'imw/dataset'
require 'fileutils'; include FileUtils::Verbose

DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS


#
# Wipe DB and add new migration
#
#DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

Processing.auto_upgrade!

# # Destroy old
# announce "Destroying old"
#
# [Dataset, Contributor, Credit, Tagging, Tag, Field, Link, Note, Payload, Rating, License, LicenseInfo, User].each do |klass|
#   puts klass.to_s
#   klass.all.each(&:destroy)
# end

# raise "Skipped! Uncomment!"


