require 'imw/dataset/datamapper'

# #
# #
# #
# class DatasetFileCollection
#   include DataMapper::Resource
#   property      :id,                    Integer,   :serial   => true
#   property      :category,              String,    :nullable => false, :unique_index => :category
#   has n,        :ripped_file_collections
# end
#
# #
# #
# # Database image of a URI object.  See
# #   http://www.ruby-doc.org/stdlib/libdoc/uri/rdoc/
# #
# # FIXME -- this should, y'know, actually be composed or inherit from URI
# #
# require 'uri'
# class DM_URI
#   include DataMapper::Resource
#   property      :id,                    Integer,   :serial   => true
#   property      :scheme,                String,    :nullable => false
#   property      :host,                  String,    :nullable => false, :unique_index => :domain
#   property      :port,                  String,    :nullable => false, :default => ''
#   property      :path,                  Text,      :nullable => false, :default => ''
#   property      :query,                 Text,      :nullable => false, :default => ''
#   property      :userinfo,              String,    :nullable => false, :default => ''
#   # property :registry, :opaque, :fragment
#
#   def self.find_or_create_from_uri uri
#     self.find_or_create_from_uri URI.extract(uri)
#   end
# end
#
# #
# #
# #
# class RippedFileCollection
#   include DataMapper::Resource
#   property      :id,                    Integer,   :serial    => true
#   has 1,        :DM_URI
#   has n,        :ripped_files
#   belongs_to    :dataset_file_collection
#
#   def self.index_siterip url
#     require 'uri'
#     uri = URI.parse(url)
#     clxn = self.find_or_create({
#         :protocol => uri.scheme, :domain => uri.host, :
#       })
#   end
# end
#
# #
# # index the raw files retrieved from website
# #
# class RippedFile
#   include DataMapper::Resource
#   property      :id,                    Integer,   :serial => true
#   property      :ripd_path,             String,    :nullable => false, :unique_index => :ripd_path
#   property      :retrieval_date,        DateTime
#   property      :compressed_size,       Integer
#   belongs_to    :ripped_file_collection
#
#   def self.from_file ripd_path, ripped_file_collection
#     ripped_file = self.find_or_create(:ripd_path => ripd_path)
#     filename = path_to(:ripd, ripd_path)
#     filedate = File.mtime(filename)
#     filesize = File.size( filename)
#     ripped_file.attributes = {
#       :ripped_file_collection => ripped_file_collection,
#       :retrieval_date  => filedate,
#       :compressed_size => filesize,
#     }
#     ripped_file.save
#     ripped_file
#   end
#
# end
