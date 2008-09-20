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
require 'imw/utils/extensions/find'
require 'net/ftp'

module IMW

  module Package

    # Upload an archived dataset with the given +title+ in +directory+
    # to archive.org.  The +directory+ should contain archives
    # (<tt>tar.gz</tt> or <tt>zip</tt>) along with (perhaps) text
    # files describing the dataset.
    def self.to_archive_org directory, title
      directory = File.expand_path(directory)
      name = File.basename(directory)
      packager = IMW::Package::ArchiveOrgPackager.new
      files = Find.files_in_directory directory

      # create xml files required by archive.org
      packager.create_files_xml File.join(directory,name + "_files.xml")

      packager.connect
      packager.make_and_enter_dir name
      
      
      

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
    class ArchiveOrgPackager

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

      # If no file format can be found in
      # <tt>IMW::Package::ArchiveOrgPackager::FILE_FORMATS</tt> then
      # use this file format.
      DEFAULT_FILE_FORMAT = "Text"
      
      attr_reader :connection

      private
      # Return the archive.org file format corresponding to +file+.
      def archive_file_format file
        match = FILE_FORMATS.find {|regex,format| regex.match(file)}
        match ? match.last : DEFAULT_FILE_FORMAT
      end

      public
      # Create an XML file at +path+ in the format required by
      # archive.org describing +files+.
      def create_files_xml path, *files
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
      # archive.org describing metadata with the given +title+.
      def create_meta_xml path, title
        xml = REXML::Document.new
        xml << REXML::XMLDecl.new
        xml.add_element "metadata"

        collection_node = xml.root.add_element("collection").text = IMW::ARCHIVE_ORG_UPLOAD_SETTINGS[:collection]
        mediatype_node = xml.root.add_element("mediatype").text = IMW::ARCHIVE_ORG_UPLOAD_SETTINGS[:mediatype]
        title_node = xml.root.add_element("title").text = title

        # FIXME this doesn't seem to actually pretty-print the way it
        # should...
        xml.write(path,2)
      end

      # Create a local directory in which to store metadata files
      # required by archive.org.
      def create_local_archive_dir dir
        FileUtils.mkdir_p dir
      end
        
      # Establish a connection to archive.org via FTP.
      def connect
        @connection = Net::FTP.new IMW::ARCHIVE_ORG_UPLOAD_SETTINGS[:server],IMW::ARCHIVE_ORG_UPLOAD_SETTINGS[:username],IMW::ARCHIVE_ORG_UPLOAD_SETTINGS[:password]
      end

      # Whether or not an active FTP connection to archive.org has
      # been made.
      def connected?
        @connection ? !@connection.closed? : nil
      end

      # Upload binary +files+ to the current remote directory.
      def upload_binary_files *files
        connect unless connected?
        files.each do |file|
          @connection.putbinaryfile(File.expand_path(file))
        end
      end

      # Upload text +files+ to the current remote directory.
      def upload_text_files *files
        files.each do |file|
          @connection.puttextfile(File.expand_path(file))
        end
      end

      # Create a directory +dir+ in the current remote directory and
      # switch to it.
      def make_and_enter_dir dir
        @connection.mkdir dir
        @connection.chdir dir
      end

    end

  end
end

# puts "#{File.basename(__FILE__)}: Keep all your bananas in one place, somewhere far, far away from you.." # at bottom
