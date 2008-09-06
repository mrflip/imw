module IMW
  class DataSet
    #
    # simple histogram
    #
    # Runs down one column/attribute of a dataset
    # returning counts for that column
    #
    def hist slicer
      counts = { }
      els = slice(slicer)
      els.each do |el|
        counts[el] ||= 0
        counts[el]  += 1
      end
      self.class.new(counts.map{ |el,ct| [ct,el] })
    end

    def slice slicer
      case
      when slicer.respond_to?(:call) then self.map{ |row| slicer.call(row) }
      else
        self.map{ |row| row[slicer] }
      end
    end

    #
    # Report
    #
    def report slicer, opts={}
      opts.reverse_merge! :n_top => 20, :hist_args => [], :fmt => "%7d\t%s", :do_hist => true
      counts = hist(slicer)
      report_hist  data, counts, slicer, opts if opts[:do_hist]
      report_sizes data, counts, slicer, opts
    end

    def report_sizes data, counts, slicer, opts={}
      fmt  = opts[:fmt]
      puts fmt % [counts.length,              "unique elements"]
      puts fmt % [data.length,                "total elements"]
      puts fmt % [counts.find_all(&:nil?).length, "nil elements"]
      uniqvals = counts.map{|ct,el| el}.reject(&:nil?)
      puts " min:\t#{uniqvals.min}"
      puts " max:\t#{uniqvals.max}"
    end

    # Most popular
    def report_hist data, counts, slicer, opts={}
      top = counts.sort_by{|ct,el| ct}[-opts[:n_top]..-1]
      puts "Top #{opts[:n_top]} elements for slice through #{slicer}:"
      puts " -freq-\t-element-"
      puts top.map{ |ct,el| opts[:fmt] % [ct,el] }
      puts "-------\t-------"
    end

  end
end
