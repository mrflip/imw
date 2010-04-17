require 'hpricot'

module Hpricot::IMWExtensions
  def contents_of path
    cnts = self.at path
    cnts.inner_html if cnts
  end
  def path_attr path, attr
    cnts = self.at path
    cnts.attributes[attr] if cnts
  end
  def class_of path
    self.path_attr_safely(path, 'class')
  end
end

class Hpricot::Elem
  include Hpricot::IMWExtensions
end

class Hpricot::Elements
  include Hpricot::IMWExtensions
end

class Hpricot::Doc
  include Hpricot::IMWExtensions
end

class Hpricot::BogusETag
  include Hpricot::IMWExtensions
end
