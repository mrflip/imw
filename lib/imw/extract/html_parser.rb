
class HTMLParser
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
    when target.is_a?(Hash)   then
      val = extract_links(content, target)
      (data[el]     ||=[]) << val unless val.blank?
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
end
