
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

wget -r -l5  --no-clobber --no-parent                     	\
    --no-verbose --background \
    -a ~/slice/var/log/wget-sitescrape-`date +%Y%m%d`.log 	\
    --wait=0.5 --random-wait --limit-rate=100k	\
    $@
