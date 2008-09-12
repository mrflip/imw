#!/usr/bin/env ruby
require 'rubygems'
require 'imw'; include IMW
require 'fileutils'; include FileUtils
require 'imw/dataset'
require 'imw/dataset/uri'
require 'imw/dataset/datamapper'
require 'imw/dataset/asset'

#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS
add_path :old_ripd, '/data/old_ripd'

class Link
  def old_file_path
    File.join(path_to(:old_ripd), uri.host, uri.path, uri.query)
  end
end

cd path_to(:old_ripd) do
  Dir['feeds.delicious.com/v2/json/userinfo/**/*'].each do |url|
    link = Link.find_or_create_from_url url
    url.update_from_file!
    puts link.file_path
  end
end
