#
# h2. lib/imw/workflow/rip/disk.rb -- obtaining data from local/remote disks
#
# == About
#
# This file implements several functions for reading data from local
# and remote filesystems into the IMW system.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/error'
require 'fileutils'

module IMW
  module Workflow
    module Rip

      # Copies data from a local disk into the directory for this
      # source.
      #
      # +local_data+ is a string or array of strings containing
      # absolute paths to files or directories that should be copied.
      # Consult <tt>FileUtils.smart_copy</tt> for useful options as
      # keyword options passed to this method will be passed down to
      # the FileUtils methods it calls.
      def rip_from_local_disk(local_data,opts={})
        @subpath = "local_disk"
        FileUtils.smart_copy(local_data,self.path_to(:ripd),opts)
      end

    end
  end  
end




# puts "#{File.basename(__FILE__)}: You gingerly dangle your Monkeywrench over the maelstrom of spinning platters and extract precisely the one you were interested in." # at bottom
