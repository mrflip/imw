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
  # and a mapping of hpricot paths to that subtree's data mapping
  # recursively extract that datamapping
  #
  def extract_tree  hdoc, content, sub_mapping
    data = { }
    sub_mapping.each do |selector, target|
      data[selector] = []
      sub_contents = content/selector
      sub_contents.each do |sub_content|
        sub_data = {}
        extract_node hdoc, sub_content, sub_data, selector, target
        data[selector] << sub_data
      end
    end
    data
    # end
    #   if selector.is_a?(String)
    #     conts = (content)
    #   else
    #     conts = [content]
    #   end
    #   conts[0..0].each do |content|
    #     extract_node hdoc, content, data, selector, target
    #   end
    # end
    data
  end



  #
  # insert the extracted element into the data mapping
  #
  def extract_node hdoc, content, data, selector, target
    classification = classify_node(selector, target)
    result = \
    case classification
    when :subtree
      target.each do |sub_selector, sub_target|
        extract_node hdoc, content, data, sub_selector, sub_target
      end

    when :sub_attribute
      k, v = selector.to_a[0]
      subcontent = (k[0..0] == '/') ? (hdoc.at(k)) : (content.at(k))
      val  = subcontent.attributes[v.to_s] if subcontent
      data[target] = val unless val.blank?

    when :attribute then
      val = content.attributes[selector.to_s]
      data[target] = val unless val.blank?

    when :flatten_list
      subcontents = (selector[0..0] == '/') ? (hdoc/selector) : (content/selector)
      data[target.first] = subcontents.map{|subcontent| subcontent.inner_html }

    when :inner_html
      subcontent = (selector[0..0] == '/') ? (hdoc.at(selector)) : (content.at(selector))
      data[target] = subcontent.inner_html.strip if subcontent

    else
      raise "classify_node shouldn't ever return #{classification}"
    end
    # puts "%-19s %-19s %-31s %s" % [target.inspect[0..18], classification.inspect[0..18], selector.inspect[0..30], result.inspect[0..90]] if (classification == :sub_attribute)
    # puts '' if classification == :subtree
  end

  def classify_node selector, target
    case
    when target.is_a?(Hash)                             then :subtree
    when selector.is_a?(Hash) && (selector.length == 1) then
      k, v = selector.to_a[0]
      case v
      when Symbol then :sub_attribute
      end
    when selector.is_a?(Symbol)                         then :attribute
    when selector.is_a?(String) && target.is_a?(Array)  then :flatten_list
    when selector.is_a?(String) && target.is_a?(Symbol) then :inner_html
    else
      raise "Can't classify mapping: " + [selector, target].join(" - ")
    end
  end

  # use #mapping to parse file
  def parse link
    begin       hdoc = Hpricot(link.contents)
    rescue;     warn "can't hpricot #{link.to_s}" ; return false;  end
    raw_taggings = extract_tree hdoc, hdoc, self.mapping
  end

  # use #mapping to parse file
  def parse_file filename
    begin       hdoc = Hpricot(File.open(filename))
    rescue;     warn "can't hpricot #{filename}" ; return false;  end
    raw_taggings = extract_tree hdoc, hdoc, self.mapping
  end
end
