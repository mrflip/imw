require 'imw/extract/line_parser'
module IMW
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
      template.gsub!(/s(\d+)/, '(.{\1,\1})')
      template.gsub!(/c/,      '(.)')
      template.gsub!(/i(\d+)/, '(.{\1,\1})')
      template.gsub!(/\s/, '')
      @cartoon_re = %r{^#{template}$}
      puts @cartoon_re, "hi"
      @cartoon_re
    end

  end

end
