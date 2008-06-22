#
# h2. imw/rip/wget.rb -- Interface to 'wget' utility
#
# == Downloading Data
#
# These functions act as an interface to the popular 'wget' utility
# for downloading data from Web resources.
#
# Other options to try:
#
# * To --accept only files with these extensions (-R to reject):
#     -A.jpg,.jpeg,.png,.gif,.htm,.html,.[xs]html,.x[sm][dl],.php,.as[px],.cgi,.pl
#   (can also force an --html-extension -k -K and you can
#   and --span-hosts --domains=... OR --exclude-domains=...
#   and --include-directories=...  OR --exclude-directories=...)
# * To --append-output log; first is brief, second gives 1M per line.
#     -nv -a wget-`date +%Y%m%d`.log     
#     -S  -a wget-`date +%Y%m%d`.log --debug --verbose --progress=dot -edot_bytes=32k -edots_in_line=32
# * To be polite:
#     --limit-rate=25k -w0.5 --tries=3 --header='From: Your Name <username@site.domain>' 
# * To be impolite:
#     --no-cache -erobots=off
# * To --convert-links to be local, getting all --page_requisites; (you 
#   can add -k -K to save the .orig inal)
#     -k -p		
# * To use --timestamping instead of just -nc for --no-clobber ; if you
#   do this *and* --convert-links you should also --backup-converted
#     -N --no-remove-listing 			
# * List of files to use:
#     --input-file=file --base=URL
#   (instead of text you can tell it it's a --force_html file)
# * Filename munging: translate a lot OR translate minimally
#   --restrict-file-names=windows     OR --restrict-file-names=unix,nocontrol
# * Chop hostname and n directory levels OR make --no-directories at all
#   -nH --cut-dirs=n  	     
#   -nd -P DIR-I-WANT-INSTEAD
#
# These can solve some problems:
#   --debug --verbose -S
#   --server-response shows headers in log, --save-headers keeps with file   
#   --post_file=file    --post-data=string	
#   --no-cache 		--no-dns-cache		--ignore_length 
#   --referer=string 	-S --password --user	--header "Cookie: name=value"
#   --user-agent="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4) Gecko/20061201 Firefox/2.0.0.4 (Ubuntu-feisty)"
#     or --user-agent="" for no user agent sent
#   
# Log in then fetch:
#   wget --save-cookies cookies.txt --keep-session-cookies --post-data 'user=foo&password=bar' <loginurl>
#   wget --load-cookies cookies.txt --keep-session-cookies <fileurl>
#
# SSL:
#   --secure-protocol=auto --no-check-certificate
#
# Also, add these to your ~/.wgetrc (command line always overrides):
#   follow_ftp 	 	 = on
#   check-certificate    = off
#   # if your conscience so allows
#   robots		 = off	
#   # cache		 = off
#   # timestamping 	 = on
#   # no-clobber 	 = on	 
#   # do ln -s or cp -p ~/.firefox/asdf/cookies.txt ~/.wget/cookies.txt
#   cookies		 = on    
#   keep-session-cookies = on
#   load_cookies	 = /home/flip/.wget/cookies.txt
#   save_cookies	 = /home/flip/.wget/cookies.txt
#   user-agent="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4) Gecko/20061201 Firefox/2.0.0.4 (Ubuntu-feisty)" 
#
# Simpler form:
#   wget -r -l5 -nc -np -nv -b -a wget.log -erobots=off -w1 $@
# 
# turn off 'background'
# mandatory: --no-clobber --no-parent --no-verbose
# options (upt o user): -r, -l, url, -limit-rate, -wait
#     * if not recursive then use -x (full path)
#     * also look at -P and -nH (for control over directories)
# make sure to (after the -a flag) specify a log in the 'dump
# section of each pool (by using the $imw.path_to(:dump,'url.log')
# think about what the end user will want to input:
# -url
# -fields
# -update frequency
# and feed.rb should do the rest
# wget -r -l5  --no-clobber --no-parent                     	\
#     --no-verbose --background \
#     -a ~/slice/var/log/wget-sitescrape-`date +%Y%m%d`.log 	\
#     --wait=0.5 --random-wait --limit-rate=100k	\
#     $@
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'imw'
require 'uri'

$imw = IMW.new_from_env() # should we be doing things this way?

# Download pages using the 'wget' utility.  The optional argument
# 'wget_path' specifies the path to the wget binary.
#
# Optional arguments to 'wget' can be provided through the 'options'
# hash which should consist of values keyed to the strings below along
# with the 'wget' flags they correspond to (parenthesis) and the
# default values (brackets).  See the man pages for 'wget' for more
# information.
# 
#  * :directory (-P) [ripd directory]
#  * :max_tries (-t) [20]
#  * :background (-b) [false]
#  * :recursive (-r) [true]
#  * :span_hosts (-H) [false]
#  * :no_directories (-nd) [false]
#  * :max_depth (-l) [5]
#  * :no_parent (-np) [true]
#  * :accept_extensions (-A) [nil]
#  * :reject_extensions (-R) [nil]
#  * :no_clobber (-nc) [true]
#  * :verbosity (-v,-nv,-q) [q]
#  * :output_file (-O) [nil]
#  * :log_file (-a) ['url.log' in dump directory]
#  * :continue (-c) [false]
#  * :wait (-w) [0.5]
#  * :random_wait (--random-wait) [true]
#  * :limit_rate (--limit-rate) [nil]
#
# Alternatively, 'options' can just be a string consisting of options
# to feed to wget directly.

Default_options = {:max_tries=>20,  :recursive=>true,:no_directories=>false,:max_depth=>5,:no_parent=>true,:no_clobber=>false,:verbosity=>'q',:continue=>false,:wait=>0.5,:random_wait=>true,:span_hosts=>false}

def wget(uri,wget_path='wget',options=nil)
  # get path to name logfile with
  uri_object = URI.parse(uri)
  path = (uri_object.host + uri_object.path).gsub('/','_') + '.' + Time.now.strftime("%Y-%M-%d_%H:%M:%S")

  if not options then options = Default_options end

  # make sure to check that no control characters are passed to wget
  cc_regex = /(#|;|\$)/
  mesg = "Control character (`#', `;', `$') found in options."
  if options.class == String then raise ArgumentError, mesg if options =~ cc_regex
  elsif options.class == Hash then
    options.each_value { |option| raise ArgumentError, mesg if option =~ cc_regex }
  end

  # clean some options
  options[:verbosity] = options[:verbosity].gsub('-','')

  # assemble command
  command = "#{wget_path} "
  if options.class == String then command += options
  elsif options.class == Hash then
    command += "-t#{options[:max_tries]} -l#{options[:max_depth]} -#{options[:verbosity]} -w#{options[:wait]} "
    flags = []
    if options[:span_hosts] then flags << "-H" end
    if options[:background] then flags << "-b" end
    if options[:recursive] then flags << "-r" end
    if options[:no_directories] then flags << "-nw" end
    if options[:no_parent] then flags << "-np" end
    if options[:no_clobber] then flags << "-nc" end
    if options[:output_file] then flags << "-O#{options[:output_file]}" end
    if options[:log_file] then flags << "-a#{options[:log_file]}" else flags << "-a#{$imw.path_to(:dump,path + ".log")}" end
    if options[:continue] then flags << "-c" end
    if options[:random_wait] then flags << "--random-wait" end
    if options[:limit_rate] then flags << "--limit-rate=#{options[:limit_rate]}" end
    if options[:accept_extensions] then flags << "-A#{options[:accept_extensions]}" end
    if options[:reject_extensions] then flags << "-R#{options[:reject_extensions]}" end
    if options[:directory] then flags << "-P#{options[:directory]}" else flags << "-P#{$imw.path_to(:ripd)}" end
    command += flags.join(' ')
  end
  puts command
end



#puts "#{File.basename(__FILE__)}: You walk through the forest jauntily clubbing trees and bushes with your Monkeywrench." # at bottom
