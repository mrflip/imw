
class Transformer
  def initialize
  end
end

#
# map html elements -- or any HTMLParser tree -- to attributes in a hash.
#   HTMLParser.new([ {
#       :name     => 'li/span.fn',
#       :location => 'li/span.adr',
#       :url      => HTMLParser.attr('li/a.url[@href]', 'href'),
#       :bio      => 'li#bio/span.bio',
#     }
#   ])
#
class HashTransformer < Transformer
  attr_accessor :match_hash
  def initialize match_hash
    # Kludge? maybe.
    raise "MatchHash requires a hash of :attributes => matchers." unless match_hash.is_a?(Hash)
    self.match_hash = match_hash
  end
  # Returns a hash mapping each attribute in match_hash
  # to the result of its matcher on the current doc tree
  def match record
    hsh = { }
    match_hash.each do |attr, src|
      val = record[src]
      hsh[attr] = val if attr
    end
  end
end
