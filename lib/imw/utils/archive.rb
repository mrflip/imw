#
# h2. lib/imw/utils/archive.rb -- classes for pushing datasets to archive.org
#
# == About
#
# We've been granted "infinite bandwidth, infinite storage" from the
# good folks at archive.org[http://www.archive.org] and we intend to
# use it!
# 
# Submitting to archive.org is a somewhat
# [complicated process][http://www.archive.org/help/contrib-advanced.php]:
#
#  1. Each contribution must have a unique name (+CONTRIBUTION+) and
#     be contained within a single directory.
#
#  2. This directory must contain two XML files in addition to its
#     content
#  
#    1. <tt>CONTRIBUTION_files.xml</tt>: a list of files in the
#       contribution in the format
#       
#       <tt><files>
#             <file name='filename1'>
#               <format>FILE_FORMAT</format>
#               <optional-metadata-1>...</optional-metadata-1>
#               ...
#             </file>
#             ...
#           </files></tt>
#
#       The <tt>FILE_FORMAT</tt> must be chosen from a fixed list of
#       formats available from
#       [archive.org][[http://www.archive.org/help/contrib-advanced.php].
#
#
#    2. <tt>CONTRIBUTION_meta.xml</tt>: metadata about the
#       contribution in the format
#
#       <tt><metadata>
#             <mediatype>MEDIATYPE</mediatype>
#             <collection>COLLECTION</collection>
#             <title>The Title to Use</title>
#             <description>A useful description of the data.</description>
#             <optional-metadata-1>...</optional-metadata-1>
#             ...
#           </metadata></tt>
#
#       The +MEDIATYPE+ and +COLLECTION+ values must match existent
#       mediatypes and collections at archive.org.  The +title+ and
#       +description+ nodes are required.  Any other information can
#       be added but is optional.
#    
#  3. The directory must be uploaded via FTP to the server
#     <tt>items-uploads.archive.org</tt> using a valid archive.org
#     account to login.
#  
#  4. To inform the "contribution engine", an <tt>HTTP GET</tt>
#     request should be issued to the address
#     <tt>http://www.archive.org/services/contrib-submit.php?user_email=EMAIL&server=SERVER&dir=CONTRIBUTION</tt>.
#     The server will issue an XML response in one of the following
#     formats.
#     
#       <tt><result type="success">
#         <message>Item successfully added</message>
#       </result></tt>
#       
#     or
#     
#       <tt><result type="error" code="ERROR_CODE">
#         <message>ERROR MESSAGE</message>
#       </result></tt>
#
# This module automates the tasks of creating the necessary XML files,
# uploading the data to archive.org, and confirming that the whole
# process went smoothly.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

module IMW

  module Archiver


    # Push this 
    def push_files_to_archive_org(step = nil)
    end

    # Push an archive of files for this dataset at 
    def push_archive_to_archive_org(step = nil)
      
    end
    

    
  end
end



# puts "#{File.basename(__FILE__)}: An wizened old monk passes you on the street and eyes your Monkeywrench, longingly." # at bottom
