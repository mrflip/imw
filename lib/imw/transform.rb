module IMW
  class Transformer
    attr_accessor :attribute
    attr_accessor :transformer
    def initialize attribute, matcher=nil
      self.attribute = attribute
      self.transformer  = transformer
    end
  end
  class RegexpRepeatedTransformer < Transformer
    attr_accessor :re
    def initialize attribute, re, transformer=nil
      super attribute, transformer
      self.re = re
    end
    def transform hsh
      raw = hsh[attribute] or return
      # get all matches
      val = raw.to_s.scan(re)
      # if there's only one capture group, flatten the array
      val = val.flatten if val.first && val.first.length == 1
      # pass to transformer, if any
      transformer ? transformer.transform(val) : val
    end
  end

  # #
  # # map html elements -- or any HTMLParser tree -- to attributes in a hash.
  # #   HTMLParser.new([ {
  # #       :name     => 'li/span.fn',
  # #       :location => 'li/span.adr',
  # #       :url      => HTMLParser.attr('li/a.url[@href]', 'href'),
  # #       :bio      => 'li#bio/span.bio',
  # #     }
  # #   ])
  # #
  # class HashTransformer < Transformer
  #   attr_accessor :match_hash
  #   def initialize match_hash
  #     # Kludge? maybe.
  #     raise "MatchHash requires a hash of :attributes => matchers." unless match_hash.is_a?(Hash)
  #     self.match_hash = match_hash
  #   end
  #   # Returns a hash mapping each attribute in match_hash
  #   # to the result of its matcher on the current doc tree
  #   def match record
  #     hsh = { }
  #     match_hash.each do |attr, src|
  #       val = record[src]
  #       hsh[attr] = val if attr
  #     end
  #   end
  # end

  # def remap mapping, src
  #   hsh = { }
  #   mapping.each{|attr, src_attr| hsh[attr] = src[src_attr] }
  #   hsh.compact
  # end

end
