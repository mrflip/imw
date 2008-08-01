module IMW
  class DataSet

    #
    # simple histogram
    #
    # Runs down one column/attribute of a dataset
    # returning counts for that column
    #
    def hist field
      counts = { }
      self.data.each do |el|
        counts[el[field]] ||= 0
        counts[el[field]]  += 1
      end
      counts.map{ |el,ct| [ct,el] }
    end

    #
    # Report
    #
    def report field, opts={}
      opts = { :n_top => 20 }.merge opts
      # Histogram
      counts = hist field
      top = counts.sort[-opts[:n_top]..-1]
      puts "Top #{opts[:n_top]} elements for field #{field}:"
      puts " -freq-\t-element-"
      puts top.map{ |el,ct| "%7d\t%s" % [el,ct] }
      # Number of elements
      puts " total:\t#{data.length} elements)"
    end

  end
end
