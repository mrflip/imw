#
# h2. lib/imw/rip.rb -- obtaining data
#
# == About
#
# Requires other files which implement specific functions to rip data
# to the local disk.  Defines a dispatcher for data sources which
# gives them a simple interface to select one of the ripping functions
# and tailors the call to that function to match the parameters of the
# source.
#
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'imw/model/source'
require 'imw/workflow/rip/local'
require 'imw/utils'

module IMW

  # There are many ways to get data into the IMW and the
  # <tt>IMW::Rip</tt> module contains functions which implement access
  # via these methods.  Functions defined here are usually named so
  # that they "sound good" when called:
  #
  #   IMW::Rip.from_local_disk ...
  #
  # Ripping can be done using these functions directly but it can also
  # be implemented by the <tt>IMW::Source.rip</tt> method which acts
  # as an interface between sources and ripping methods and dispatches
  # to the correct ripping method when requested to by a source.
  module Rip
  end
end


module IMW

  class Source

    # Known methods to rip data.
    KNOWN_RIPPING_METHODS = [:local_disk]

    # Rip data to this source's +ripd+ directory:
    #
    #   source.rip_from :local_disk, "~/data", "~/file1.dat", Dir["/var/data"]
    #
    # Possible ripping methods are defined in
    # <tt>IMW::Source::KNOWN_RIPPING_METHODS</tt>.
    #
    # Keyword arguments can be given and include:
    #
    # <tt>:comment</tt>:: a comment to be associated with the task created for ripping this data
    def rip_from method, *args
      list,opts = args.last.is_a?(Hash) ? [args.most, args.last] : [args, {}]
      
      raise IMW::Error.new("Ripping methid (#{method}) must be one of the symbols in IMW::Source::KNOWN_RIPPING_METHODS (#{KNOWN_RIPPING_METHODS.quote_items_with 'or'})") unless KNOWN_RIPPING_METHODS.include? method

      @workflow[:rip].enhance do
        case method
        when :local_disk
          IMW::Rip.from_local_disk(path_to(:ripd), *list)
        end
      end

      @workflow[:rip].add_comment(opts[:comment]) if opts[:comment]
      
    end
  end
end

# puts "#{File.basename(__FILE__)}: Dark branches crack like thunder at dusk as your Infinite Monkeywrench rips through the dense undergrowth." # at bottom
