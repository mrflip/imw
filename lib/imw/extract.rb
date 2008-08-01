
module IMW

  class LineOrientedFile
    attr_accessor :fields
    attr_accessor :file, :filepath

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
      [:filepath, :cartoon, :fields].each do |field|
        self.send("#{field}=", options[field])
      end
      self.fields.map!{ |f| f.to_sym }
      self.file = File.open(path_to(self.filepath))
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

  class WeatherStationFile < FlatFile
    def fix_coords sgn, value, scale = 1
      return nil if value == "99999"
      (sgn=="+" ? 1 : -1) * (value.to_f) / scale
    end

    def records
      recs = super()
      recs.map do |rec_in|
        rec_out = { }
        [:USAF_weatherstation_code, :WBAN_weatherstation_code,
          :country_code_wmo, :country_code_fips, :us_state, :ICAO_call_sign
        ].each do |f|
          rec_out[f] = rec_in[f].rstrip
        end

        rec_out[:lat]   = fix_coords(rec_in[:lat_sign],  rec_in[:lat],  1000)
        rec_out[:lng]   = fix_coords(rec_in[:lng_sign],  rec_in[:lng],  1000)
        rec_out[:elev]  = fix_coords(rec_in[:elev_sign], rec_in[:elev],   10)
        rec_out
      end
    end
  end

end
