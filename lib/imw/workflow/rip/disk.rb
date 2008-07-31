#
# h2. lib/imw/workflow/rip/disk.rb -- ripping data from local disk
#
# == About
#
# Contains methods for ripping data from the local disk to the
# appropriate source directory.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw/utils/error'
require 'imw/utils/fileutils_extensions'

module IMW
  module Workflow
    module Rip

      # Copies data from a local disk into the appropriate directory
      # for +source+.
      def from_local_disk_to source
        


        
        @source = "local_disk"
        FileUtils.mkdir_p(self.path_to(:ripd)) if not File.exist?(self.path_to(:ripd))
        FileUtils.smart_copy(local_data,self.path_to(:ripd),opts)
      end

    end
  end
end

# puts "#{File.basename(__FILE__)}: You gingerly dangle your Monkeywrench over the maelstrom of spinning platters and extract precisely the one you were interested in." # at bottom
