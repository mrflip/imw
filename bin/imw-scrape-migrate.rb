#!/usr/bin/env ruby
require 'rubygems'
require 'imw'; include IMW
require 'fileutils'; include FileUtils

#
# Old ripped location
#
add_path :old_ripd, '/data/old_ripd'
class Link
  def old_file_path
    file_path_str = ""
    file_path_str << uri.path.to_s
    file_path_str << "?#{uri.query}"        unless uri.query.nil?
    file_path_str << "##{uri.fragment}"     unless uri.fragment.nil?
    File.join(*[path_to(:old_ripd), uri.host, file_path_str].compact)
  end
end

require 'imw/dataset'
require 'imw/dataset/uri'
require 'imw/dataset/datamapper'
require 'imw/dataset/asset'

# DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS

cd path_to(:old_ripd) do
  links = []
  Dir['*delicious.com/**/*'].reject{|f| ! File.file?(f) }.each do |old_ripd_file|
    track_count :files, 200
    link = Link.find_or_new_from_url 'http://'+old_ripd_file

    # move to ripd
    dest = path_to(:ripd_root, link.file_path)
    if File.exist?(dest)
      # puts "exists: #{dest}"
    else
      mkdir_p File.dirname(dest)
      # puts "moving: #{dest}"
      copy_file old_ripd_file, dest, true
    end

    # Update the file info
    link.update_from_file!
    links << link

    links.each(&:save) if (links.length % 100 == 0)
  end
  links.each(&:save)
end




# cd path_to(:ripd_root) do
#   Dir['com.delicious.feeds/**/*'].reject{|f| !File.file?(f) }.each do |ripd_file|
#     link = Link.find_or_create_from_url(Link.url_from_file_path(ripd_file))
#     puts "different! #{ripd_file} and #{link.file_path}" unless (ripd_file == link.file_path)
#     # if File.exist?(path_to(:ripd_root, link.file_path)) && !File.exist?(link.old_file_path)
#     #   puts "Missing: #{link.old_file_path} for #{link.file_path}"
#     # end
#   end
# end
# Link.all.each do |link|
#   if File.exist?(path_to(:ripd_root, link.file_path)) && !File.exist?(link.old_file_path)
#     puts "Missing: #{link.old_file_path} for #{link.file_path}"
#   end
# end
