#
# h2. lib/imw/utils/extensions/hpricot.rb -- extensions to hpricot
#
# == About
#
# Some IMW extensions for Why's Hpricot library.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'hpricot'

module Hpricot::IMWExtensions

  # Return the contents of the first element to match +path+.
  def contents_of path
    cnts = self.at path
    cnts.inner_html if cnts
  end

  # Return the value of +attr+ for the first element to match +path+.
  def path_attr path, attr
    cnts = self.at path
    cnts.attributes[attr] if cnts
  end

  # Return the value of the +class+ attribute of the first element to
  # match +path+.
  def class_of path
    self.path_attr(path, 'class')
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
