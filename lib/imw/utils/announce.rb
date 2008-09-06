#
# h2. lib/imw/utils.rb -- utility functions
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/utils/error'
require 'imw/utils/announce'
require 'imw/utils/config'
require 'imw/utils/paths'
require 'imw/utils/extensions/core'

# puts "#{File.basename(__FILE__)}: Early economists thought they would measure the utility of an action in units of `utils'.  Really." # at bottom

module IMW
  class << self; attr_accessor :verbose end
  self.verbose = true

  def announce str
    return unless IMW.verbose
    puts "#{Time.now}\t" + str.to_s
    $stdout.flush
  end
  def banner str
    return unless IMW.verbose
    puts "*"*75
    announce str
    puts "*"*75
  end

  PROGRESS_TRACKERS = {}
  #
  # When the slowly-changine tracked variable +var+ changes value,
  # announce its new value.  Always announces on first call.
  #
  # Ex:
  #   track_progress :indexing_names, name[0..0] # announce at each initial letter
  #   track_progress :files, (i % 1000)          # announce at each 1,000 iterations
  #
  def track_progress tracker, val
    unless (IMW::PROGRESS_TRACKERS.include?(tracker)) &&
           (IMW::PROGRESS_TRACKERS[tracker] == val)
      announce "  #{tracker.to_s.gsub(/_/,' ')}: #{val}"
      IMW::PROGRESS_TRACKERS[tracker] = val
    end
  end

  PROGRESS_COUNTERS = {}
  def track_count tracker, every=1000
    PROGRESS_COUNTERS[tracker] ||= 0
    PROGRESS_COUNTERS[tracker]  += 1
    track_progress tracker, every * (PROGRESS_COUNTERS[tracker] / every).to_i
  end

end
