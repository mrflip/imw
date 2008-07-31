#
# h2. imw/rip/feed.rb -- Tools for downloading feeds.
#
# These functions read data from a feed at a given URI and download it
# to a directory ('ripd') where it can be stored until it is
# processed.  By default, only new data is downloaded and added to
# this directory.
#
#
# == Supported Feeds
#
# * RSS
# 
# 
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 


require 'rss'
require 'imw'

$imw = IMW.new_from_env() # should we be doing things this way?

# Returns a renamed version of the channel suitable for including in a
# filename
def rename_channel(channel,max_size=200)
  channel.slice!(max_size,channel.size)
  channel.gsub!(' ','_')
  channel.gsub!('/','::') # is this a good choice?
  return channel
end

def rss_download(uri,download_all=false) 
  rss = RSS::Parser.parse(uri,do_validate=false)
  filename = rename_channel(rss.channel.title) + '_RSS.xml'
  filepath = "#{$imw.path_to(:ripd)}/#{filename}"

  # try to stat the filename and if it doesn't exist
  # just download the entire RSS feed
  begin File::Stat.new(filepath) rescue Errno::ENOENT download_all = true end

  if not download_all then 
    old_rss = RSS::Parser.parse(filepath,do_validate=false)
    new_items = []

    if rss.items.size == rss.items.find_all {|item| item.guid}.size && 
        old_rss.items.size == old_rss.items.find_all {|item| item.guid}.size then
      # if all items have a guid then use it to find the new ones
      old_guids = old_rss.items.map {|item| item.guid.content }
      rss.items.each {|item| if old_guids.member?(item.guid.content) then new_items << item end } 
    else
      # match the actual items against one another (it might be
      # worthwhile to just do this anyway/instead of using guid above)
      rss.items.each {|item| if not old_rss.items.member?(item) then new_items << item end }
    end
    # this is the wrong way to add items to an RSS feed because there
    # isn't even an '=' method for 'rss.items'...so here is some silly
    # workaround.  someone who knows how to use the RSS library better
    # should do this the right way...
    old_rss.items.reverse!
    new_items.reverse.each do |item| old_rss.items << item end
    old_rss.items.reverse!
    File.open(filepath,'w') {|file| file.write(old_rss.to_xml) }
  else
    # download the whole nut
    File.open(filepath,'w') {|file| file.write(rss.to_xml) }
  end
end

puts "#{File.basename(__FILE__)}: Though your belly is full and your mind at rest you just...can't...stop...feeding..." # at bottom
