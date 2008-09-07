#
# h2. lib/imw/workflow/package/to_archive.rb -- push dataset to archive.org
#
# == About
#
# The nice folks at archive.org[http://www.archive.org] have agreed to
# host datasets in a special Infochimps collection.  The process for
# uploading to archive.org is reasonably complicated and the functions
# defined here automate that process.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'rexml/document'
require 'imw/utils'
require 'net/ftp'

module IMW

  module Package

    # Archive.org accepts uploads of one directory at a time through
    # FTP.  The directory being uploaded must contain two special XML
    # files If the name of the directory is +DIRECTORY+ then the first
    # of these files must be named <tt>DIRECTORY_files.xml</tt> and is
    # of the form
    # 
    #   <files>
    #     <file name='filename1.ext'>
    #       <format>FILE_FORMAT</format>
    #       <optional-metadata-1>...</optional-metadata-1>
    #       ...
    #     </file>
    #   </files>
    #
    # The second XML file must be named <tt>DIRECTORY_meta.xml</tt>
    # and is of the form
    # 
    #   <metadata>
    #     <collection>name_of_collection</collection>
    #     <mediatype>mediatype</mediatype>
    #     <title>The Title to Use</title>
    #     <optional-metadata-1>...</optional-metadata-1>
    #     ....
    #   </metadata>
    #
    # Infochimps has a special +infochimps+ collection where data can
    # be stored with the mediatype +data+.
    #
    # Once a directory is prepared with the appropriate data in these
    # two XML files it can be uploaded via FTP to the server
    # <tt>items-uploads.archive.org</tt> using an approved username
    # and password.
    module Archive

      attr_reader :connection

      # Username for arhive.org FTP upload (should be set in
      # user-configuration file).
      USERNAME = "" unless defined? USERNAME

      # Password for arhive.org FTP upload (should be set in
      # user-configuration file).
      PASSWORD = "" unless defined? PASSWORD

      # Server for arhive.org FTP upload (should be set in
      # user-configuration file).
      SERVER = "items-uploads.archive.org" unless defined? SERVER

      # Collection for arhive.org FTP upload (should be set in
      # user-configuration file).
      COLLECTION = "Infochimps" unless defined? COLLECTION

      # Mediatype for arhive.org FTP upload (should be set in
      # user-configuration file).
      MEDIATYPE = "Data" unless defined? MEDIATYPE

      # Archive.org only allows certain kinds of file format strings.
      # They are listed at
      # http://www.archive.org/help/contrib-advanced.php.  Here are
      # relevant ones for uploading datasets.
      FILE_FORMATS = {
        /\.tar$/ => "TAR",
        /\.tar.\gz$/ => "TGZiped Text Files",
        /\.tgz$/ => "TGZiped Text Files",
        /\.zip$/ => "ZIP"
      }

      # Return the archive.org file format corresponding to +file+.
      def self.archive_file_format file
        FILE_FORMATS.find {|regex,format| regex.match(file)}.last
      end

      # Create an XML file at +path+ in the format required by
      # archive.org describing +files+.
      def self.create_files_xml path, *files
        xml = REXML::Document.new
        xml << REXML::XMLDecl.new
        xml.add_element "files"

        files.each do |file|
          file_node = xml.root.add_element "file", {"name" => File.basename(file)}
          format_node = file_node.add_element("format").text = archive_file_format(file)
        end

        # FIXME this doesn't seem to actually pretty-print the way it
        # should...
        xml.write(path,2)
      end

      # Create an XML file at +path+ in the format required by
      # archive.org describing metadata.
      def self.create_meta_xml path, title
        xml = REXML::Document.new
        xml << REXML::XMLDecl.new
        xml.add_element "metadata"

        collection_node = xml.root.add_element("collection").text = COLLECTION
        mediatype_node = xml.root.add_element("mediatype").text = MEDIATYPE
        title_node = xml.root.add_element("title").text = title

        # FIXME this doesn't seem to actually pretty-print the way it
        # should...
        xml.write(path,2)
      end

      # Initiate a connection to the archive.org FTP server and return
      # it.
      def self.connect
        @connection = Net::FTP.new SERVER,USERNAME,PASSWORD
      end

    end
    
  end
end
        
# puts "#{File.basename(__FILE__)}: Keep all your bananas in one place, somewhere far, far away from you.." # at bottom
