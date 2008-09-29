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

# puts "#{File.basename(__FILE__)}: Early economists thought they would measure the utility of an action in units of `utils'.  Really." # at bottom

require 'logger'
#
# http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/
#

module IMW
  LOG_FILE_DESTINATION = STDERR             unless defined?(LOG_FILE_DESTINATION)
  LOG_TIMEFORMAT       = "%Y%m%d-%H:%M:%S " unless defined?(LOG_TIMEFORMAT)

  class << self; attr_accessor :log end
  #
  # Create a Logger and point it at LOG_FILE_DESTINATION
  #
  # LOG_FILE_DESTINATION is STDOUT by default; redefine it in your
  # ~/.imwrc, or set IMW.log yourself, if that's not cool.
  #
  def self.instantiate_logger!
    IMW.log ||= Logger.new(LOG_FILE_DESTINATION)
    IMW.log.datetime_format = "%Y%m%d-%H:%M:%S "
    IMW.log.level           = Logger::INFO
  end

  def announce *events
    options = events.extract_options!
    options.reverse_merge! :level => Logger::INFO
    # puts [options, events ].inspect, "*"*76
    IMW.log.add options[:level], events.join("\n")
  end
  def banner *events
    options = events.extract_options!
    options.reverse_merge! :level => Logger::INFO
    ["*"*75, events, "*"*75].flatten.each{|ev| announce(ev, options) }
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
      announce "#{tracker.to_s.gsub(/_/,' ')}: #{val}"
      IMW::PROGRESS_TRACKERS[tracker] = val
    end
  end

  PROGRESS_COUNTERS = {}
  #
  # Log repetitions in a given context
  #
  # At every n'th (default 1000) call,
  # announce progress in the IMW.log
  #
  def track_count tracker, every=1000
    PROGRESS_COUNTERS[tracker] ||= 0
    PROGRESS_COUNTERS[tracker]  += 1
    chunk = every * (PROGRESS_COUNTERS[tracker]/every).to_i
    track_progress "count_of_#{tracker}", chunk
  end
end

#
# Make the default logger
#
IMW.instantiate_logger!
