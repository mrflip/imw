



Goal is *brevity* and *speed of programming* rather than *efficiency of final
code*

Where efficiency of final code becomes important, 

---------------------------------------------------------------------------


Patterns in Munging Data


h3. TaskTracker

Process a series of objects [idempotent]ly:
* Take each object in order of (given) priority.
* Pass each object in turn to a Processor;
* log and timestamp the attempt;
* record a timestamp for the attempt;
* record a result code and extended description for its outcome.

No task (within optional time window) is repeated.  Tasks can be inserted into the queue at any time and with any priority.  Only rough order of priority is guaranteed.

ex. 
*Scraping*: for each (depth-first search of a wildcarded URL path), (retrieve using wget into a URIFileStore); save (HTTP result code) and (wget's output)

h3. ChunkStore

For 
* Collection of URIs
* Place & scheme to store them
* Fetcher to retrieve them

Lazily fetch documents: 
* 
* Store the retrieval timestamp
* Cache the document's metadata.

ex.
*URIFileStore* save each URI to a file whose name safely but recognizably corresponds to the original URI
*Document DB* such as GraphDB or Lucene
*Compressed* URI refers to files within a compressed package.  When file is demanded expand the package into scratch space.
*InfochimpsMetadataset* Lazily retrieve the dataset+schema for an infochimps metadataset, lazily produce its (compressed) contents.


h3. Extract

* Given chunks of formatted data
** either in a common input format: xml, yaml, csv
** or parsed to a defined data structure
* return a stream of records.


ex.
  CSVExtractor.new()  # use field names from first line to
                        construct a Struct class on the fly
                        return each line as struct
  Extract("foo.csv")  # same as CSVExtractor.new.extract("foo.csv")
  Extract("foo.yaml") # 
  Extract("foo.xml")  # Return the "natural" (a la XML Simple) object tree
  HTMLExtractor (see below)
  
  
h4. HTML Extractor

* Map repeating HTML elements into data records
  Defining the document structure also defines the data structure
* Hpricot:   http://code.whytheluckystiff.net/hpricot/wiki
* Selectors: http://docs.jquery.com/DOM/Traversing/Selectors

== Sample HTML (http://twitter.com:

  <ul class="about vcard entry-author">
    <li         ><span class="label">Name</span>     <span class="fn" >MarsPhoenix       </span> </li>
    <li         ><span class="label">Location</span> <span class="adr">Mars, Solar System</span> </li>
    <li id="bio"><span class="label">Bio</span>      <span class="bio">I dig Mars!       </span> </li>
    <li         ><span class="label">Web</span>
       <a href="http://tinyurl.com/5wwaru" class="url" rel="me nofollow">http://tinyurl.co...</a></li>
  </ul>

== Parser Spec:
  :hcard        => m_one('//ul.vcard.about',
    {
      :name     => 'li/span.fn',
      :location => 'li/span.adr',
      :url      => m_attr('li/a.url[@href]', 'href'),
      :bio      => 'li#bio/span.bio',
    }
  )

== Example return:
  { :hcard => { :name => 'Mars Phoenix', :location => 'Mars, Solar System', :bio => 'I dig Mars!', :url => 'http://tinyurl.com/5wwaru' } }
  
== Sample HTML (http://delicious.com):
  <ul id="bookmarklist" class="bookmarks NOTHUMB">
    <li class="post" id="item-...">
      <div class="bookmark NOTHUMB">
        <div class="dateGroup">         <span title="23 APR 08">23 APR 08</span>     </div>
        <div class="data">
          <h4>                          <a rel="nofollow" class="taggedlink" href="http://www.cs.biu.ac.il/~koppel/BlogCorpus.htm">Blog Authorship Corpus (Blogger.com 1994)</a>
                                        <a class="inlinesave" href="...">SAVE</a> </h4>
          <h5 class="savers-label">     PEOPLE</h5>
          <div class="savers savers2">  <a class="delNav" href="/url/7df6661946fca61863312644eb071953"><span class="delNavCount">26</span></a>  </div>
          <div class="description">     The Blog Authorship Corpus consists of the collected posts of 19,320 bloggers gathered from blogger.com in August 2004. The corpus incorporates a total of 681,288 posts and over 140 million words - or approximately 35 posts and 7250 words per person. </div>
        </div>
        <div class="meta"></div>
        <h5 class="tag-chain-label">TAGS</h5>
        <div class="tagdisplay">
          <ul class="tag-chain">
            <li class="tag-chain-item off first"><a class="tag-chain-item-link" rel="tag" href="/infochimps/blog"     ><span class="tag-chain-item-span">blog</span>    </a></li>
            <li class="tag-chain-item off">      <a class="tag-chain-item-link" rel="tag" href="/infochimps/corpus"   ><span class="tag-chain-item-span">corpus</span>  </a></li>
            <li class="tag-chain-item off">      <a class="tag-chain-item-link" rel="tag" href="/infochimps/analysis" ><span class="tag-chain-item-span">analysis</span></a></li>
            <li class="tag-chain-item off">      <a class="tag-chain-item-link" rel="tag" href="/infochimps/nlp"      ><span class="tag-chain-item-span">nlp</span>     </a></li>
            <li class="tag-chain-item on  last"> <a class="tag-chain-item-link" rel="tag" href="/infochimps/dataset"  ><span class="tag-chain-item-span">dataset</span> </a></li>
          </ul>
        </div>
        <div class="clr"></div>
      </div>
    </li>
  </ul>

== Parser Specification:
  :bookmarks            => [ 'ul#bookmarklist/li.post/.bookmark',
    {
      :date                     => hash(    '.dateGroup/span', 
         [:year, :month, :day]  => regexp(  '', /(\d{2}) ([A-Z]{3}) (\d{2})/),
         ),
      :title                    =>          '.data/h4/a.taggedlink',
      :url                      => attr(    '.data/h4/a.taggedlink', 'href'), 
      :del_link_url             => href(    '.data/.savers/a.delNav),          
      :num_savers               => to_i(    '.data/.savers//span.delNavCount'),
      :description              =>          '.data/.description',
      :tags                     =>         ['.tagdisplay//tag-chain-item-span']
    }
  ]

== Example output:
  { :bookmarks => [
    { :date             => { :year => '08', :month => 'APR', :day => '23' },
      :title            => 'Blog Authorship Corpus (Blogger.com 1994)',
      :url              => 'http://www.cs.biu.ac.il/~koppel/BlogCorpus.htm',
      :del_link_url     => '/url/7df6661946fca61863312644eb071953',
      :num_savers       => 26,
      :description      => 'The Blog ... ',
      :tags             => ['blog', 'corpus', 'analysis', 'nlp', 'dataset'],
     }
   ]}

== Implementation:

Internally, we take the spec and turn it into a recursive structure of Matcher
objects.  These consume Hpricot Elements and return the appropriately extracted
object.

Note that the /default/ is for a bare selector to match ONE element, and to not
complain if there are many.

Missing elements are silently ignored -- for example if
  :foo => 'li.missing'
there will simply be no :foo element in the hash (as opposed to having hsh[:foo]
set to nil -- hsh.include?(foo) will be false)

   
== List of Matchers:
    { :field => /spec/, ... }           # hash          hash, each field taken from spec.
    [ "hpricot_path" ]                  # 1-el array    array: for each element matching 
                                                        hpricot_path, the inner_html
    [ "hpricot_path", /spec/ ]          # 2-el array    array: for each element matching 
                                                        hpricot_path, pass to spec
    "hpricot_path"                      # string        same as one("hpricot_path")
    one("hpricot_path")                 # one           first match to hpricot_path 
    one("hpricot_path", /spec/)         # one           applies spec to first match to hpricot_path     
    (these all match on one path:)
    regexp("hpricot_path", /RE/)        # regexp        capture groups from matching RE against
                                                        inner_html of first match to hpricot_path
    attr("hpricot_path", 'attr_name')   # attr
    href("hpricot_path")                # href          shorthand for attr(foo, 'href')
    no_html                             #               strip tags from contents
    html_encoded                        #               html encode contents
    to_i, to_f, etc                     # convert       
    lambda{|doc| ... }                  # proc          calls proc on current doc
    
== Complicated HCard example:
    :hcards                     =>      [ '//ul.users/li.vcard',
      {
        :name                   =>      '.fn',
        :address                =>      one('.adr', 
          :street               =>      '.street',
          :city                 =>      '.city',
          :zip                  =>      '.postal'
        )
        :tel                    =>      [ 'span.tel',
          {
            :type               =>      'span.type',
            [:cc, :area, :num]  =>      hp.regexp('span.value', /+(\d+).(\d{3})-(\d{3}-\d{4})/),
          }
        ]
        :tags                   =>      [ '.tag' ],
      }
    ]

== Resulting Parser
    MatchHash({:hcards  =>      MatchArray('//ul.users/li.hcard',
      MatchHash({
        :name                   =>      MatchFirst('.fn'),
        :address                =>      MatchFirst('.adr',
          MatchHash({
            :street             =>      MatchFirst('.street'),
            :city               =>      MatchFirst('.locality),
            :state              =>      MatchFirst('.region),
            :zip                =>      MatchFirst('.postal'),
          }))
        :tel                    =>      MatchArray('span.tel',
          MatchHash({
            :type               =>      MatchFirst('span.type'),
            [:cc, :area, :num]  =>      RegexpMatcher('span.value', /+(\d+).(\d{3})-(\d{3}-\d{4})/),
          })
        )
        :tags                   =>      MatchArray('.tag'),
      })
    )

== Example output
    [
      {:tel     => [ {:type => 'home', :cc => '49', :area => '305', :num => '555-1212'},
                     {:type => 'work', :cc => '49', :area => '305', :num => '555-6969'}, ],
       :name    => "Bob Dobbs, Jr.",
       :tags    => ["church"] },        
      {:tel     => [ {:type => 'fax',  :cc => '49', :area => '305', :num => '867-5309'}, ],
       :name    => "Jenny",
       :address => { :street => "53 Evergreen Terr.", :city => "Springfield" },
       :tags    => ["bathroom", "wall"] },      
    ]
    

h3. Transform

* map fields across
* simple unit conversion

Field Mapper

  NaturalMapper.map(raw, out)   		# map fields in raw onto fields that exist in out
  			 			# 

  RegexpMapper( [:tel], [:cc, :tel],
		/\a\s*\+(\d+)?[\.\- ]?          # (optional) country code
		       ( \d{3}[\.\- ]           # area code
		         \d{3}[\.\- ]           # exchange
		         \d{4}       )\s*\Z/x,  # last four
  		:warn => :tel) 			# on regexp miss, warn and put contents into output 

h3. Schema

* Terse description of 

h4. Dump

* Export schematized, self-aware data as objects / tables into many formats


h3. Reconcile

* 

h4. Detect Duplicates

h4. Repair faulty records, leaving original intact


Reporter

Report progress, set application-level status messages and update Counters.
Tasks can use the Reporter to report progress or just indicate that they are alive. 
Applications can also update Counters using the Reporter.


File store

    appendage		_host_encoded(user)_encoded(password)
			all but [a-zA-Z0-9] are encoded in user and password.
			if scheme is HTTP and port, user, password are 80, nil and nil then the appendage is ''
			otherwise all three parts are appended
    full_revhost 	"#{revhost}#{appendage}"
    tld_tier		'_' + part of the encoded_revhost up to first '.'
    host_tier 		'_' + first two characters if any of sld (remainder of full_revhost after first '.'
    encode pathsegs	split path with %r{/+}
    	   		blank pathsegs are removed
    	   		all characters outside of [A-Za-z0-9_-.] are encoded
			additionally, leading non-alpha are encoded.
    [tiered_pathsegs]   encoded pathsegs, optional intermediate tiers (having leading _) inserted if necessary.
    ext			part of the file following and including its last '.'.
    			Note that the filename is left untouched; this is just re-appended for convenience's sake
    uuid		UUID.sha1_create(UUID_URL_NAMESPACE, url)
    filename		encode(file?query#fragment)+uuid-date.ext
    			since a '+' in a filename or path segment is encoded, a pathseg and filename will never collide.

  For the URL http://twitter.com/statuses/friends/bob.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT fetched at 4:20:00pm on 2008 Nov 4,

  URL parts:
      revhost,     port, user, password, path,	      	     file,    query,					 fragment
    [ com.twitter, nil,  nil,  nil,      'statuses/friends', bob.xml, since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT, nil   
  File parts:
    [_tld_tier, _revhost_tier, revhost_scheme_port_user_password, [path, path, path].map(&:encode), encode(file?query#fragment), uuid(url), datetime, ext]
  Result:
    tld_tier 		_com
    revhost_tier	_tw
    full_revhost	com.twitter
    tiered_pathsegs     [statuses, friends, _bo]
    filename		bob.xml%3Fsince%3DTue%252C%2B27%2BMar%2B2007%2B22%253A55%253A48%2BGMT
    uuid 		76eb6d0ad6fe5ae0b3128ec5e4a7a72f
    timestamp		20081104-162000
    ext 		.xml

  path:
    '_com/_tw/com.twitter/statuses/friends/_bo/bob.xml+3b78498d83a755e89b6e10cf7612ad8a+20081104-162000.xml'
    '_com/_tw/com.twitter/statuses/friends/_bo/bob.xml%3Fsince%3DTue%252C%2B27%2BMar%2B2007%2B22%253A55%253A48%2BGMT+76eb6d0ad6fe5ae0b3128ec5e4a7a72f+20081104-162000.xml'

  decoding:
    split on '/'
    discard all tiers /^_.*/
    first part is full_revhost.
      extract port, user and password if there
      unreverse revhost
    decode remaining pathsegs
    split filename, uuid, timestamp, extension.
    decode filename

  * you can find a uri with find -name "*+UUID_GOES_HERE+*"
  * the revhost etc means that files from common domains will appear together in
    file listing, INNODB indexes, etc
  
  
  path segments that start with _ are culled (these are 'tiers' to handle huge
  collections of files otherwise in the same directory)


      m = (%r{\A
            (#{Addressable::URI::HOST_TLD})  # tld tier
           /(..?)                            # revhost tier
           /([^/\:_]+)                       # revhost
        (?:_([^/\:]+))?                      # _scheme
        (?::(\d*):([^/]*)@([^@/]*?))?        # :port:user@password
           /(?:(.*?)/)?                      # /dirs/
            ([^/]*)                          #  file
           -([a-f0-9]{32})                   # -uuid
                                \z}x.match(fp))
  
