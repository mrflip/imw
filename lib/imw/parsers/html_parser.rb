#
# h2. lib/imw/parsers/html_parser.rb -- html parser
#
# == About
#
# h4. HTML Extractor
#
# * map repeating HTML elements to intermediate ruby data structure
# * optimize all the common cases for expressive brevity
# * output structure will come from HTML structure; map to desired output objects in transform stage.
# * spec shouldn't be allowed to get too much more complicated than this; again, transform stage exists
#
# If this doesn't yield satisfaction you may enjoy
# * http://blog.labnotes.org/2006/07/11/scraping-with-style-scrapi-toolkit-for-ruby/
# * http://scrubyt.org/
# Note of course that these have quite different goals.  For example, we don't
# have any interest in "interactive" crawling, eg form submission, or at least
# that goes elsewhere.
#
#
# == Sample HTML (http://twitter.com):
#
#   <ul class="about vcard entry-author">
#     <li         ><span class="label">Name</span>     <span class="fn" >MarsPhoenix       </span> </li>
#     <li         ><span class="label">Location</span> <span class="adr">Mars, Solar System</span> </li>
#     <li id="bio"><span class="label">Bio</span>      <span class="bio">I dig Mars!       </span> </li>
#     <li         ><span class="label">Web</span>
#        <a href="http://tinyurl.com/5wwaru" class="url" rel="me nofollow">http://tinyurl.co...</a></li>
#   </ul>
#
# == Parser Spec:
#   :hcard        => m_one('//ul.vcard.about',
#     {
#       :name     => 'li/span.fn',
#       :location => 'li/span.adr',
#       :url      => m_attr('li/a.url[@href]', 'href'),
#       :bio      => 'li#bio/span.bio',
#     }
#   )
#
# == Example return:
#   { :hcard => { :name => 'Mars Phoenix', :location => 'Mars, Solar System', :bio => 'I dig Mars!', :url => 'http://tinyurl.com/5wwaru' } }
#
# == Sample HTML (http://delicious.com):
#   <ul id="bookmarklist" class="bookmarks NOTHUMB">
#     <li class="post" id="item-...">
#       <div class="bookmark NOTHUMB">
#         <div class="dateGroup">         <span title="23 APR 08">23 APR 08</span>     </div>
#         <div class="data">
#           <h4>                          <a rel="nofollow" class="taggedlink" href="http://www.cs.biu.ac.il/~koppel/BlogCorpus.htm">Blog Authorship Corpus (Blogger.com 1994)</a>
#                                         <a class="inlinesave" href="...">SAVE</a> </h4>
#           <h5 class="savers-label">     PEOPLE</h5>
#           <div class="savers savers2">  <a class="delNav" href="/url/7df6661946fca61863312644eb071953"><span class="delNavCount">26</span></a>  </div>
#           <div class="description">     The Blog Authorship Corpus consists of the collected posts of 19,320 bloggers gathered from blogger.com in August 2004. The corpus incorporates a total of 681,288 posts and over 140 million words - or approximately 35 posts and 7250 words per person. </div>
#         </div>
#         <div class="meta"></div>
#         <h5 class="tag-chain-label">TAGS</h5>
#         <div class="tagdisplay">
#           <ul class="tag-chain">
#             <li class="tag-chain-item off first"><a class="tag-chain-item-link" rel="tag" href="/infochimps/blog"     ><span class="tag-chain-item-span">blog</span>    </a></li>
#             <li class="tag-chain-item off">      <a class="tag-chain-item-link" rel="tag" href="/infochimps/corpus"   ><span class="tag-chain-item-span">corpus</span>  </a></li>
#             <li class="tag-chain-item off">      <a class="tag-chain-item-link" rel="tag" href="/infochimps/analysis" ><span class="tag-chain-item-span">analysis</span></a></li>
#             <li class="tag-chain-item off">      <a class="tag-chain-item-link" rel="tag" href="/infochimps/nlp"      ><span class="tag-chain-item-span">nlp</span>     </a></li>
#             <li class="tag-chain-item on  last"> <a class="tag-chain-item-link" rel="tag" href="/infochimps/dataset"  ><span class="tag-chain-item-span">dataset</span> </a></li>
#           </ul>
#         </div>
#         <div class="clr"></div>
#       </div>
#     </li>
#   </ul>
#
# == Parser Specification:
#   :bookmarks            => [ 'ul#bookmarklist/li.post/.bookmark',
#     {
#       :date                     => hash(    '.dateGroup/span',
#          [:year, :month, :day]  => regexp(  '', /(\d{2}) ([A-Z]{3}) (\d{2})/),
#          ),
#       :title                    =>          '.data/h4/a.taggedlink',
#       :url                      => attr(    '.data/h4/a.taggedlink', 'href'),
#       :del_link_url             => href(    '.data/.savers/a.delNav),
#       :num_savers               => to_i(    '.data/.savers//span.delNavCount'),
#       :description              =>          '.data/.description',
#       :tags                     =>         ['.tagdisplay//tag-chain-item-span']
#     }
#   ]
#
# == Example output:
#   { :bookmarks => [
#     { :date             => { :year => '08', :month => 'APR', :day => '23' },
#       :title            => 'Blog Authorship Corpus (Blogger.com 1994)',
#       :url              => 'http://www.cs.biu.ac.il/~koppel/BlogCorpus.htm',
#       :del_link_url     => '/url/7df6661946fca61863312644eb071953',
#       :num_savers       => 26,
#       :description      => 'The Blog ... ',
#       :tags             => ['blog', 'corpus', 'analysis', 'nlp', 'dataset'],
#      }
#    ]}
#
# == Implementation:
#
# Internally, we take the spec and turn it into a recursive structure of Matcher
# objects.  These consume Hpricot Elements and return the appropriately extracted
# object.
#
# Note that the /default/ is for a bare selector to match ONE element, and to not
# complain if there are many.
#
# Missing elements are silently ignored -- for example if
#   :foo => 'li.missing'
# there will simply be no :foo element in the hash (as opposed to having hsh[:foo]
# set to nil -- hsh.include?(foo) will be false)
#
#
# == List of Matchers:
#     { :field => /spec/, ... }           # hash          hash, each field taken from spec.
#     [ "hpricot_path" ]                  # 1-el array    array: for each element matching
#                                                         hpricot_path, the inner_html
#     [ "hpricot_path", /spec/ ]          # 2-el array    array: for each element matching
#                                                         hpricot_path, pass to spec
#     "hpricot_path"                      # string        same as one("hpricot_path")
#     one("hpricot_path")                 # one           first match to hpricot_path
#     one("hpricot_path", /spec/)         # one           applies spec to first match to hpricot_path
#     (these all match on one path:)
#     regexp("hpricot_path", /RE/)        # regexp        capture groups from matching RE against
#                                                         inner_html of first match to hpricot_path
#     attr("hpricot_path", 'attr_name')   # attr
#     href("hpricot_path")                # href          shorthand for attr(foo, 'href')
#     no_html                             #               strip tags from contents
#     html_encoded                        #               html encode contents
#     to_i, to_f, etc                     # convert
#     lambda{|doc| ... }                  # proc          calls proc on current doc
#
# == Complicated HCard example:
#     :hcards                     =>      [ '//ul.users/li.vcard',
#       {
#         :name                   =>      '.fn',
#         :address                =>      one('.adr',
#           :street               =>      '.street',
#           :city                 =>      '.city',
#           :zip                  =>      '.postal'
#         )
#         :tel                    =>      [ 'span.tel',
#           {
#             :type               =>      'span.type',
#             [:cc, :area, :num]  =>      hp.regexp('span.value', /+(\d+).(\d{3})-(\d{3}-\d{4})/),
#           }
#         ]
#         :tags                   =>      [ '.tag' ],
#       }
#     ]
#
# == Resulting Parser
#     MatchHash({:hcards  =>      MatchArray('//ul.users/li.hcard',
#       MatchHash({
#         :name                   =>      MatchFirst('.fn'),
#         :address                =>      MatchFirst('.adr',
#           MatchHash({
#             :street             =>      MatchFirst('.street'),
#             :city               =>      MatchFirst('.locality),
#             :state              =>      MatchFirst('.region),
#             :zip                =>      MatchFirst('.postal'),
#           }))
#         :tel                    =>      MatchArray('span.tel',
#           MatchHash({
#             :type               =>      MatchFirst('span.type'),
#             [:cc, :area, :num]  =>      RegexpMatcher('span.value', /+(\d+).(\d{3})-(\d{3}-\d{4})/),
#           })
#         )
#         :tags                   =>      MatchArray('.tag'),
#       })
#     )
#
# == Example output
#     [
#       {:tel     => [ {:type => 'home', :cc => '49', :area => '305', :num => '555-1212'},
#                      {:type => 'work', :cc => '49', :area => '305', :num => '555-6969'}, ],
#        :name    => "Bob Dobbs, Jr.",
#        :tags    => ["church"] },
#       {:tel     => [ {:type => 'fax',  :cc => '49', :area => '305', :num => '867-5309'}, ],
#        :name    => "Jenny",
#        :address => { :street => "53 Evergreen Terr.", :city => "Springfield" },
#        :tags    => ["bathroom", "wall"] },
#     ]
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: Something clever" # at bottom

require 'imw/parsers/html_parser/matchers'

module IMW
  module Parsers
    class HtmlParser

      include IMW::Parsers::HtmlMatchers

      attr_accessor :parse_tree

      #
      # Parse Tree
      #
      def initialize arg_spec=nil
        spec = arg_spec || self.class.parser_spec
        self.parse_tree = IMW::Parsers::HtmlMatchers.build_parse_tree(spec)
      end

      #
      # See IMW::HtmlParser for syntax
      #
      #
      def self.parser_spec
        raise "Override this to create your own parser spec"
      end

      #
      # Walk
      #
      def parse doc
        self.parse_tree.match(doc)
      end

      # one("hpricot_path")                 first match to hpricot_path
      # one("hpricot_path", /spec/)         applies spec to first match to hpricot_path
      #
      def self.one selector, matcher
        MatchFirstElement.new(selector, IMW::Parsers::HtmlMatchers.build_parse_tree(matcher))
      end
      # match the +attr+ attribute of the first element given by +selector+
      def self.attr selector, attr, matcher=nil
        MatchAttribute.new(selector, attr, IMW::Parsers::HtmlMatchers.build_parse_tree(matcher))
      end
      # shorthand for +attr(foo, 'href')+
      def self.href selector, matcher=nil
        self.attr(selector, 'href', matcher)
      end
      # shorthand for +attr(foo, 'src')+
      def self.src selector, matcher=nil
        self.attr(selector, 'src', matcher)
      end

      def self.proc selector, proc, matcher=nil
        MatchProc.new(selector, proc, IMW::Parsers::HtmlMatchers.build_parse_tree(matcher))
      end

      # strip ","s (!! thus disrespecting locale !!!)
      # and convert to int
      def self.to_num selector, matcher=nil
        proc selector, lambda{|num| num.to_s.gsub(/,/,'').to_i if num }, matcher
      end
      def self.to_json selector, matcher=nil
        proc selector, lambda{|v| v.to_json if v }, matcher
      end

      def self.strip selector, matcher=nil
        proc selector, lambda{|v| v.strip }, matcher
      end

      def self.re_group selector, re
        MatchRegexp.new(selector, re)
      end
      def self.re selector, re
        MatchRegexp.new(selector, re, nil, :capture => 1)
      end
      def self.re_all selector, re, matcher=nil
        MatchRegexpRepeatedly.new(selector, re)
      end

      # def self.plain_text selector, matcher=nil
      #   proc selector, lambda{|el| el.inner_text if el }, matcher
      # end

      # attr_accessor :mapping
      #
      # #
      # # Feed me a hash and I'll semantify HTML
      # #
      # # The hash should magically adhere to the too-complicated,
      # # ever evolving goatrope that works for the below
      # #
      # #
      # def initialize mapping
      #   self.mapping = mapping
      # end
      #
      # #
      # # take a document subtree,
      # # and a mapping of hpricot paths to that subtree's data mapping
      # # recursively extract that datamapping
      # #
      # def extract_tree  hdoc, content, sub_mapping
      #   data = { }
      #   sub_mapping.each do |selector, target|
      #     data[selector] = []
      #     sub_contents = content/selector
      #     sub_contents.each do |sub_content|
      #       sub_data = {}
      #       extract_node hdoc, sub_content, sub_data, selector, target
      #       data[selector] << sub_data
      #     end
      #   end
      #   data
      #   # end
      #   #   if selector.is_a?(String)
      #   #     conts = (content)
      #   #   else
      #   #     conts = [content]
      #   #   end
      #   #   conts[0..0].each do |content|
      #   #     extract_node hdoc, content, data, selector, target
      #   #   end
      #   # end
      #   data
      # end
      #
      # #
      # # insert the extracted element into the data mapping
      # #
      # def extract_node hdoc, content, data, selector, target
      #   classification = classify_node(selector, target)
      #   result = \
      #   case classification
      #   when :subtree
      #     target.each do |sub_selector, sub_target|
      #       extract_node hdoc, content, data, sub_selector, sub_target
      #     end
      #
      #   when :sub_attribute
      #     k, v = selector.to_a[0]
      #     subcontent = (k[0..0] == '/') ? (hdoc.at(k)) : (content.at(k))
      #     val  = subcontent.attributes[v.to_s] if subcontent
      #     data[target] = val unless val.blank?
      #
      #   when :attribute then
      #     val = content.attributes[selector.to_s]
      #     data[target] = val unless val.blank?
      #
      #   when :flatten_list
      #     subcontents = (selector[0..0] == '/') ? (hdoc/selector) : (content/selector)
      #     data[target.first] = subcontents.map{|subcontent| subcontent.inner_html }
      #
      #   when :inner_html
      #     subcontent = (selector[0..0] == '/') ? (hdoc.at(selector)) : (content.at(selector))
      #     data[target] = subcontent.inner_html.strip if subcontent
      #
      #   else
      #     raise "classify_node shouldn't ever return #{classification}"
      #   end
      #   # puts "%-19s %-19s %-31s %s" % [target.inspect[0..18], classification.inspect[0..18], selector.inspect[0..30], result.inspect[0..90]] if (classification == :sub_attribute)
      #   # puts '' if classification == :subtree
      # end
      #
      # def classify_node selector, target
      #   case
      #   when target.is_a?(Hash)                             then :subtree
      #   when selector.is_a?(Hash) && (selector.length == 1) then
      #     k, v = selector.to_a[0]
      #     case v
      #     when Symbol then :sub_attribute
      #     end
      #   when selector.is_a?(Symbol)                         then :attribute
      #   when selector.is_a?(String) && target.is_a?(Array)  then :flatten_list
      #   when selector.is_a?(String) && target.is_a?(Symbol) then :inner_html
      #   else
      #     raise "Can't classify mapping: " + [selector, target].join(" - ")
      #   end
      # end
      #
      # # use #mapping to parse file
      # def parse link
      #   begin       hdoc = Hpricot(link.contents)
      #   rescue;     warn "can't hpricot #{link.to_s}" ; return false;  end
      #   raw_taggings = extract_tree hdoc, hdoc, self.mapping
      # end
      #
      # # use #mapping to parse file
      # def parse_file filename
      #   begin       hdoc = Hpricot(File.open(filename))
      #   rescue;     warn "can't hpricot #{filename}" ; return false;  end
      #   raw_taggings = extract_tree hdoc, hdoc, self.mapping
      # end
    end
  end
end

