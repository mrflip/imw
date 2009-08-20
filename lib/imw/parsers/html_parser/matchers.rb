


#
# h2. lib/imw/parsers/html_parser/matcher.rb -- utility classes for html parser
#
# == About
#
# This file defines the <tt>IMW::HTMLParserMatcher::Matcher</tt>
# abstract class and some concrete subclasses which perform specific
# kinds of matches against HTML documents using the
# Hpricot[https://code.whytheluckystiff.net/hpricot/] library.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/utils/extensions/hpricot'

module IMW
  module HTMLParserMatcher

    # An abstract class from which to subclass specific HTML matchers.
    # 
    # A subclass is initialized with a +selector+ and an optional
    # +matcher+.  The +selector+ is an HTML path specification used to
    # collect elements from the document.  If initialized with a
    # +matcher+, the +matcher+ is used to return match information
    # from the elements; else the inner HTML is returned.  Subclasses
    # decide how the +selector+ will collect elements.
    class Matcher
      
      attr_accessor :selector
      attr_accessor :matcher
      attr_accessor :options      
      
      def initialize selector, matcher=nil, options={}
        self.selector = selector
        self.matcher  = matcher
        self.options  = options
      end

      def match doc
        raise "Abstract class #{self.class}"
      end
      
    end

    # Concrete subclass of <tt>IMW::HTMLParserMatcher::Matcher</tt>
    # for matching against the first element of a document matching a
    # selector.
    class MatchFirstElement < Matcher
      # Grab the first element from +doc+ matching the +selector+ this
      # class was initialized with.  If initialized with a +matcher+,
      # then return the +matcher+'s match against the first element,
      # else just return the inner HTML of the first element.
      # 
      #   m = MatchFirstElement.new('span#bio/a.homepage')
      #   m.match('<span id="bio"><a class="homepage" href="http://foo.bar">My Homepage</a></span>')
      #   # => 'My Homepage'
      def match doc
        doc = Hpricot(doc) if doc.is_a?(String)
        el = doc.at(selector) or return nil
        if matcher
          matcher.match(el)
        else
          options[:html] ? el.inner_html : el.inner_text.strip
        end
      end
    end

    # FIXME is there really a need for this separate class?  why can't
    # MatchFirstElement.match accept a block?
    class MatchProc < MatchFirstElement
      attr_accessor :proc
      attr_accessor :options
      def initialize selector, proc, matcher=nil, options={}
        super selector, matcher
        self.options = options
        self.proc = proc
      end
      def match doc
        val = super doc
        val ? self.proc.call(val) : self.proc.call(doc)
      end
    end    

    # Concrete subclass of <tt>IMW::HTMLParserMatcher::Matcher</tt>
    # for matching each element of a document matching a selector.
    class MatchArray < Matcher
      # Grab each element from +doc+ matching the +selector+ this
      # class was initialized with.  If initialized with a +matcher+,
      # then return an array consisting of the +matcher+'s match
      # against each element, else just return an array consisting of
      # the inner HTML of each element.
      # 
      #   m = MatchArray.new('span#bio/a.homepage')
      #   m.match('<span id="bio"><a class="homepage" href="http://foo.bar">My Homepage</a></span>
      #            <span id="bio"><a class="homepage" href="http://foo.baz">Your Homepage</a></span>
      #            <span id="bio"><a class="homepage" href="http://foo.qux">Their Homepage</a></span>')
      #   # => ["My Homepage", "Your Homepage", "Their Homepage"]
      def match doc
        doc = Hpricot(doc) if doc.is_a?(String)        
        subdoc = (doc/selector) or return nil
        if matcher
          subdoc.map{|el| matcher.match(el)}
        else
          if options[:html]
            subdoc.map{|el| el.inner_html }
          else
            subdoc.map{|el| el.inner_text.strip }
          end
        end
      end
    end

    # Concrete subclass of <tt>IMW::HTMLParserMatcher::Matcher</tt>
    # for matching an attribute of the first element of a document
    # matching a selector.
    class MatchAttribute < Matcher

      attr_accessor :attribute

      # Unlike <tt>IMW::HTMLParserMatcher::Matcher</tt>,
      # <tt>IMW::HTMLParserMatcher::MatchAttribute</tt> is initialized
      # with three arguments: the +selector+ which collects elements
      # from an HTML document, an +attribute+ to extract, and
      # (optionally) a +matcher+ to perform the matching.
      def initialize selector, attribute, matcher=nil
        super selector, matcher
        self.attribute = attribute.to_s
      end
      
      # Grab the first element from +doc+ matching the +selector+ this
      # class was initialized with.  If initialized with a +matcher+,
      # then return the +matcher+'s match against the value of the
      # +attribute+ this class was initialized with, else just return
      # the value of the +attribute+.
      # 
      #   m = MatchAttribute.new('span#bio/a.homepage', 'href')
      #   m.match('<span id="bio"><a class="homepage" href="http://foo.bar">My Homepage</a></span>')
      #   # => 'http://foo.bar'
      def match doc
        doc = Hpricot(doc) if doc.is_a?(String)        
        val = doc.path_attr(selector, attribute)
        matcher ? matcher.match(val) : val
      end
    end

    # Concrete subclass of <tt>IMW::HTMLParserMatcher::Matcher</tt>
    # for using a regular expression to match against text in an HTML
    # document.
    class MatchRegexp < Matcher
      
      attr_accessor :re
      attr_accessor :options

      # Use the regular expression +re+ to return captures from the
      # elements collected by +selector+ (treated as text) used on an
      # HTML document (if +selector+ is +nil+ then match against the
      # full text of the document).  If the keyword argument
      # <tt>:capture</tt> is specified then return the corresponding
      # group (indexing is that of regular expressions; "1" is the
      # first capture), else return an array of all captures.  If
      # +matcher+, then use it on the capture(s) before returning.
      #
      # FIXME Shouldn't the matcher come BEFORE the regexp capture,
      # not after?
      def initialize selector, re, matcher=nil, options={}
        super selector, matcher
        self.options = options
        self.re = re
      end

      # Grab the first element from +doc+ matching the +selector+ this
      # object was initialized with.  Use the +re+ and the (optional)
      # capture group this object was initialized with to capture a
      # string (or array of strings if no capture group was specified)
      # from the collected element (treated as text). If initialized
      # with a +matcher+, then return the +matcher+'s match against
      # the value of the capture(s), else just return the capture(s).
      # 
      #   m = MatchRegexp.new('span#bio/a.homepage', /Homepage of (.*)$/, nil, :capture => 1 )
      #   m.match('<span id="bio"><a class="homepage" href="http://foo.bar">Homepage of John Chimpo</a></span>')
      #   # => "John Chimpo"
      def match doc
        doc = Hpricot(doc) if doc.is_a?(String)        
        el = selector ? doc.contents_of(selector) : doc
        m = re.match(el.to_s)
        val = case
              when m.nil? then nil
              when self.options.key?(:capture) then m.captures[self.options[:capture] - 1] # -1 to match regexp indexing
              else m.captures
              end
        # pass to matcher, if any
        matcher ? matcher.match(val) : val
      end
    end

    
    class MatchRegexpRepeatedly < Matcher
      attr_accessor :re
      def initialize selector, re, matcher=nil
        super selector, matcher
        self.re = re
      end
      def match doc
        doc = Hpricot(doc) if doc.is_a?(String)        
        # apply selector, if any
        el = selector ? doc.contents_of(selector) : doc
        return unless el
        # get all matches
        val = el.to_s.scan(re)
        # if there's only one capture group, flatten the array
        val = val.flatten if val.first && val.first.length == 1
        # pass to matcher, if any
        matcher ? matcher.match(val) : val
      end
    end
    
    # Class for building a hash of values by using appropriate
    # matchers against an HTML document.
    class MatchHash

      attr_accessor :match_hash

      # The +match_hash+ must be a +Hash+ of symbols matched to HTML
      # matchers (subclasses of
      # <tt>IMW::HTMLParserMatcher::Matcher</tt>).
      def initialize match_hash
        # Kludge? maybe.
        raise "MatchHash requires a hash of :attributes => matchers." unless match_hash.is_a?(Hash)
        self.match_hash = match_hash
      end

      # Use the +match_hash+ this +MatchHash+ was initialized with to
      # select elements from +doc+ and extract information from them:
      #
      #   m = MatchHash.new({
      #       :name         => MatchFirstElement.new('li/span.customer'),
      #       :order_status => MatchAttribute.new('li/ul[@status]','status'),
      #       :products     => MatchArray.new('li/ul/li')
      #     })
      #   m.match('<li><span class="customer">John Chimpo</span>
      #                <ul status="shipped">
      #                  <li>bananas</li>
      #                  <li>mangos</li>
      #                  <li>banangos</li>
      #                </ul></li>')
      #   # => {
      #         :name         => "John Chimpo",
      #         :order_status => "shipped",
      #         :products     => ["bananas", "mangos", "banangos"]
      #        }
      def match doc
        doc = Hpricot(doc) if doc.is_a?(String)        
        hsh = { }
        match_hash.each do |attr, m|
          val = m.match(doc)
          case attr
          when Array then hsh.merge!(Hash.zip(attr, val).reject{|k,v| v.nil? }) if val
          else            hsh[attr] = val  end
        end
        self.class.scrub!(hsh)
      end
      
      # kill off keys with nil values
      def self.scrub! hsh
        hsh # .reject{|k,v| v.nil? }
      end
    end

    #
    # construct the downstream part of a hash matcher
    #
    def self.build_match_hash spec_hash
      hsh = { }
      spec_hash.each do |attr, spec|
        hsh[attr] = build_parse_tree(spec)
      end
      hsh
    end

    #
    # recursively build a tree of matchers
    #
    def self.build_parse_tree spec
      case spec
      when nil            then nil
      when Matcher        then spec
      when Hash           then MatchHash.new(build_match_hash(spec))
      when Array          then
        return nil if spec.empty?
        raise "Array spec must be a single selector or a selector and another match specification" unless (spec.length <= 2)
        MatchArray.new(spec[0].to_s, build_parse_tree(spec[1]))
      when String         then MatchFirstElement.new(spec)
      when Proc           then MatchProc.new(nil, spec)
      when Regexp         then MatchRegexp.new(nil, spec, nil, :capture => 1)
      else raise "Don't know how to parse #{spec.inspect}"
      end
    end
  end
end
