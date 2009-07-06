#
# h2. lib/imw/dataset/loaddump.rb -- read and write datasets to resources
#
# == About
#
# Implements methods to load a dataset from a resource and to write a
# dataset back to a resource.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/utils'

module IMW
  class Dataset

    # Return the data in +filename+ in an appropriate form.
    #
    # FIXME How do I get pass a block from one method to another?
    def self.load filename, &block
      filename = path_to(filename)      
      announce "Loading #{filename}"
      file = IMW.open(filename)
      data = file.load(filename)
      if block
        data.each{|record| yield record}
        file
      else
        data
      end
    end

    # Dump +data+ to +filename+.
    def self.dump data, filename
      filename = path_to(filename)
      announce "Dumping to #{filename}"
      IMW.open(filename,'w').dump(data)
    end

    # Dispatch to <tt>Dataset.dump</tt>.
    def dump filename
      self.class.dump self.data, *args
    end

  end
end
