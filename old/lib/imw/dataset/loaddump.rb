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
