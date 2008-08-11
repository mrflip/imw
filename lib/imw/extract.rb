
module IMW

  class LineOrientedFile
    attr_accessor :fields, :struct
    attr_accessor :file

    def skip_lines n_lines
      return unless self.file
      #self.file.lineno = self.file.lineno + n_lines
      n_lines.times do self.file.gets end
    end

    def rows
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

  class FlatFile < LineOrientedFile
    attr_accessor :cartoon, :cartoon_re

    def initialize(options)
      [:file, :cartoon, :fields].each do |field|
        self.send("#{field}=", options[field])
      end
      self.fields.map!{ |f| f.to_sym }
      self.struct = Struct.new(*fields)
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
      %r{^#{template}}
    end

  end

end
