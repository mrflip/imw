
module IMW

  class LineOrientedFileParser
    attr_accessor :fields, :skip_head
    # the Struct factory each record will be mapped to
    attr_accessor :struct

    #
    #
    # +:fields+         List of symbols giving field names of resultant struct.
    # +:skip_head+      Initial lines to skip in file
    #
    def initialize(options)
      self.skip_head = options[:skip_head] || 0
      self.struct = Struct.new(*options[:fields].map{ |f| f.to_sym })
    end

    #
    # Skip (unconditionally) a given number of lines in the file
    #
    def skip_lines file, n_lines
      return unless file
      #self.file.lineno = self.file.lineno + n_lines # KLUDGE why doesn't this work?
      n_lines.times do file.gets end
    end

    #
    #
    #
    def parse iter, &block
      line_num = 0
      iter.map do |line|

      end
      rows = []
      while line = self.file.gets do
        rows << decode_line(line)
      end
      rows
    end

    def records
      rows.map{|row| Hash.zip(self.fields, row) }
    end

  end

  class FlatFileParser < LineOrientedFileParser
    attr_accessor :cartoon, :cartoon_re

    def initialize(options)
      super(options)
      [:cartoon, ].each do |field|
        self.send("#{field}=", options[field])
      end
    end

    def decode_line line
      m = cartoon_re.match(line)
      m ? m.captures : []
    end

    def cartoon_re
      return @cartoon_re if @cartoon_re
      template = cartoon.gsub(/\A\s+/,'').split(/\n/).first
      template.gsub!(/s(\d+)/, '(.{\1})')
      template.gsub!(/c/,      '(.)')
      template.gsub!(/i(\d+)/, '(.{\1})')
      template.gsub!(/\s/, '')
      @cartoon_re = %r{^#{template}$}
    end

  end

end
