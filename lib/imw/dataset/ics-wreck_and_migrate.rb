#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/.'
require 'ics-models.rb'
require 'fileutils'; include FileUtils

# #
# # Wipe DB and add new migration
# #
DataMapper.auto_migrate!


# Destroy old
announce "Destroying old"
# Info, Search, Talk,
[Contributor, Credit, Dataset, Tagging, Tag, Field, Link, Note, Payload, Rating, RightsStatement, License, User].each do |klass|
  klass.all.each{ |l| l.destroy }
end


# raise "Skipped! Uncomment!"


