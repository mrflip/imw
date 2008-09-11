require 'imw/extract/hpricot'
class HTMLParser
  attr_accessor :mapping

  #
  # Feed me a hash and I'll semantify HTML
  #
  # The hash should magically adhere to the too-complicated,
  # ever evolving goatrope that works for the below
  #
  #
  def initialize mapping
    self.mapping = mapping
  end

  #
  # take a document subtree,
  # and a mapping of hpricot paths to that subtree's data structure
  # recursively extract that datastructure
  #
  def extract_links  hdoc, structure
    data = {}
    structure.each do |el, target|
      if el.is_a?(String)
        conts = (hdoc/el)
      else
        conts = [hdoc]
      end
      conts.each do |content|
        extract_link data, content, el, target
      end
    end
    data
  end

  #
  # insert the extracted element into the data structure
  #
  def extract_link data, content, el, target
    case
    # subtree
    when target.is_a?(Hash)   then
      val = extract_links(content, target)
      (data[el]     ||=[]) << val unless val.blank?
    # element -> attribute terminal pair
    when el.is_a?(Hash) then
      warn("attribute terminal should be hash of one pair") if el.length != 1
      k, v = el.to_a[0]
      val  = (content.at(k)).attributes[v.to_s] if (content.at(k))
      data[target] = val unless val.blank?
    when el.is_a?(Symbol) then
      val = content.attributes[el.to_s]
      (data[target] ||=[]) << val unless val.blank?
    when el.is_a?(String) && target.is_a?(Array) then
      (data[target.first] ||=[]) << content.inner_html.strip
    when el.is_a?(String) && target.is_a?(Symbol) then
      data[target] = content.inner_html.strip
    else
      raise "crapsticks: " + [data.inspect, content.to_s[0..200], el, target].join(" - ")
    end
  end

  # use #mapping to parse file
  def parse_html_file html_file
    begin       hdoc = Hpricot(File.open(File.expand_path(html_file)))
    rescue;     warn "can't hpricot #{html_file}" ; return false;  end
    extract_links hdoc, self.mapping
  end
end
