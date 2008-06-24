#
# h2. lib/imw/rip/http.rb -- obtaining data from the web through HTTP
#
# == About
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
require 'imw/utils/config'
require 'imw/utils/misc'
require 'fileutils'

module IMW
  module Workflow
    module Rip

      #--
      # FIXME need to add support for authentication, post, ssl, etc.
      #++
      #
      # Download pages from +urls+ using the +wget+ utility into this
      # source's <tt>:ripd</tt> directory, filed by the first URL in
      # the list of URLs to download.
      #
      # Options (with their default values in parentheses) include:
      #
      # <b>Download options</b>
      #
      # <tt>:max_tries</tt> (20):: Maximum number of tries before giving up.  Set to 0 for infinite retrying.  Fatal errors like "connection refused" or "not found" (404) are not retried.
      # <tt>:background</tt> (false):: Go to background immediately.
      # <tt>:recursive</tt> (true):: Recurse into directories and follow hyperlinks.
      # <tt>:span_hosts</tt> (false):: Allow downloading from multiple domains.
      # <tt>:include_domains</tt> ([]):: Limit downloading to the domains listed.
      # <tt>:exclude_domains</tt> ([]):: Prevent downloading from the domains listed.
      # <tt>:max_depth</tt> (5):: The maximum depth of directories to recurse to.
      # <tt>:no_parent</tt> (true):: Do not recurse to directories above those specified explicitly.
      # <tt>:include_extensions</tt> ([]):: Download only files matching the given extensions.
      # <tt>:exclude_extensions</tt> ([]):: Do not download files matching the given extensions.
      # <tt>:continue</tt> (false):: Continue a previously interrupted download.
      # <tt>:wait</tt> (0.5):: Wait the given number of seconds between retrievals.  Suffixes of +m+, +h+, or +d+ can be appended for minutes, hours, or days, respectively.
      # <tt>:random_wait</tt> (true):: Randomly vary the waiting interval between retrievals.
      # <tt>:limit_rate</tt> (nil):: Limit the downloading rate to the given amount, specified with suffixes of +k+ or +m+ to denote kilobytes or megabytes.
      # <tt>:user</tt> (nil):: Specify a username to use when authenticating.
      # <tt>:password</tt> (nil):: Specify a password to use when authenticating.
      # <tt>:only_new</tt> (false):: Download only those files which are new and/or modified from the ones on the local disk.
      # <tt>:ignore_length</tt> (false):: Prevent a problem with some CGI programs sending bogus <tt>Content-Length</tt> headers which cause +wget+ to die on the same document at the same byte over and over again.
      # <tt>:include_directories</tt> ([]):: Download only from the given directories.
      # <tt>:exclude_directories</tt> ([]):: Do not download from the given directories.
      #
      # <b>Local options</b>
      #
      # <tt>:no_directories</tt> (false):: Do not create a local hierarchy of directories when retrieving recursively (duplicate filenames will have index numbers appended to them).
      # <tt>:no_clobber</tt> (false):: Do not download files that already exist on disk.
      # <tt>:force_directories</tt> (false):: Create a directory structure on the local disk even if one doesn't exist on the server.
      # <tt>:remove_host_prefix</tt> (true):: Remove the hostname prefix from the local directory structure (<tt>http://fly.srk.fer.hr/robots.txt</tt> will be placed into <tt>robots.txt</tt>)
      # <tt>:cut_directories</tt> (nil):: Remove the given number of directory prefixes (<tt>fftp://ftp.xemacs.org/pub/xemacs/index.html</tt> will download to <tt>pub/xemacs/index.html</tt> with an argument of 1 and to <tt>xemacs/index.html</tt> with an argument of 2, etc.)
      #
      # <b>Miscellaneous options</b>
      #
      # <tt>:verbose</tt> ('v'):: Control level of verbosity: +v+ - print everything, +nv+ - print basic information and error message, or +q+ - pring nothing.
      # <tt>:wget_path</tt> ('wget'):: Path to the +wget+ program.
      #
      # More information about these options can be found by reading the manual for Wget.
      def rip_with_wget(urls,user_opts={})

        # process urls and define @source for this source
        if urls.class == String then urls = [urls] end
        @source = reverse_domain(urls.first)
        
        # default values for options
        options = {:max_tries => 20, :background => false, :recursive => true, :span_hosts => false,\
          :include_domains => [], :exclude_domains => [], :max_depth => 5, :no_parent => true,\
          :include_extensions => [], :exclude_extensions => [], :continue => false, :wait => 0.5,\
          :random_wait => true, :limit_rate => nil, :user => nil, :password => nil, :only_new => false,\
          :ignore_length => false, :include_directories => [], :exclude_directories => [],\
          :no_directories => false, :no_clobber => false, :force_directories => false,\
          :remove_host_prefix => true, :cut_directories => nil, :verbose => 'v',:wget_path => 'wget'}
        # update default options with user supplied options
        options.update(user_opts)

        # wget long-form flags for each option
        option_flags = {:max_tries => "tries", :background => "background", :recursive => "recursive",\
          :span_hosts => "span-hosts", :include_domains => "domains", :exclude_domains => "exclude-domains",\
          :max_depth => "level", :no_parent => "no-parent", :include_extensions => "accept",\
          :exclude_extensions => "reject", :continue => "continue", :wait => "wait",\
          :random_wait => "random-wait", :limit_rate => "limit-rate", :user => "user",\
          :password => "password", :only_new => "timestamping", :ignore_length => "ignore-length",\
          :include_directories => "include-directories", :exclude_directories => "exclude-directories",\
          :no_directories => "no-directories", :no_clobber => "no-clobber",\
          :force_directories => "force-directories", :remove_host_prefix => "no-host-directories",\
          :cut_directories => "cut-dirs"}
        # flags that will actually be passed to wget
        flags = []
        
        # process boolean options
        [:background, :recursive, :span_hosts, :no_parent, :continue, :random_wait,\
         :only_new, :ignore_length, :no_directories, :no_clobber, :force_directories,\
         :remove_host_prefix].each do |opt|
          if options[opt] then
            flags << "--#{option_flags[opt]}"
          end
        end
        
        # process options with argument lists
        [:include_domains, :exclude_domains, :include_extensions, :exclude_extensions,\
         :include_directories, :exclude_directories].each do |opt|
          if options[opt].length > 0 then
            flags << "--#{option_flags[opt]}=#{options[opt].join(',')}"
          end
        end
        
        # process other options
        flags << "--#{option_flags[:max_tries]}=#{options[:max_tries]}"
        flags << "--#{option_flags[:max_depth]}=#{options[:max_depth]}"
        flags << "--#{option_flags[:wait]}=#{options[:wait]}"
        flags << "--#{option_flags[:limit_rate]}=#{options[:limit_rate]}" if options[:limit_rate]
        flags << "--#{option_flags[:user]}=#{options[:user]}" if options[:user]
        flags << "--#{option_flags[:password]}=#{options[:password]}" if options[:user]
        flags << "--#{option_flags[:cut_directories]}=#{options[:cut_directories]}" if options[:cut_directories]
        case options[:verbose]
        when 'v' then
          flags << "--verbose"
        when 'nv' then
          flags << "--no-verbose"
        when 'q' then
          flags << "--quiet"
        else
          flags << "--verbose"
        end
        
        # log file
        flags << "--append-output=#{self.path_to(:ripd)}/#{Time.now.strftime(IMW::TimestampFormat)}.log"
        # get directories to dump files in
        flags << "--directory-prefix=#{self.path_to(:ripd)}"
        
        # construct command
        command = "#{options[:wget_path]} #{flags.join(' ')} #{urls.join(' ')}"

        # create the ripd directory to hold the downloaded data only
        # if it doesn't already exist
        if not File.exist?(self.path_to(:ripd)) then FileUtils.mkdir_p(self.path_to(:ripd)) end

        # run command
        system(command)
        raise IMW::Error.new("Error in invoking wget (error code: #{$?.exitstatus}).  Command was #{command}") unless $?.success?

      end

    end
  end
end

#puts "#{File.basename(__FILE__)}: You walk through the forest jauntily clubbing trees and bushes with your Monkeywrench." # at bottom
