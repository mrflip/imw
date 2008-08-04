require 'hpricot'

class Hpricot::Elem
  def contents_of path
    cnts = self.at path
    cnts.inner_html if cnts
  end
  def class_of path
    cnts = self.at path
    cnts.attributes['class'] if cnts
  end
end

class Hpricot::Elements
  def contents_of path
    cnts = self.at path
    cnts.inner_html if cnts
  end
  def class_of path
    cnts = self.at path
    cnts.attributes['class'] if cnts
  end
end
