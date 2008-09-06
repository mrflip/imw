require 'imw/dataset/datamapper'
require 'imw/dataset/datamapper/uri'

#
# All the files associated with a given URL
#
class DatasetFileCollection
  include DataMapper::Resource
  property      :id,                    Integer,   :serial   => true
  property      :category,              String,    :nullable => false, :unique_index => :category
  has n,        :ripped_file_collections

end

#
# Collection of raw files retrieved from a spider based at a given URL
#
class RippedFileCollection
  include DataMapper::Resource
  property      :id,                    Integer,   :serial    => true
  belongs_to    :url, :class_name => DM_URI, :child_key => [:url_id]
  has n,        :ripped_files
  belongs_to    :dataset_file_collection

  def self.find_or_create_from_url url, dataset_file_collection
    url = DM_URI.find_or_create_from_url(url)
    ripdfiles = self.find_or_create(
      { :url_id => url.id },
      { :dataset_file_collection => dataset_file_collection})
  end

  def listing_filename()
    path_to(:rawd, "listing-#{url.as_flat_filename}.txt")
  end

  def make_listing_file
    return if File.exist?(listing_filename)
    FileUtils.cd path_to(:ripd_root) do
      `find #{url.as_path} > #{listing_filename}`
    end
  end

  # Mon Aug 11 08:59:00 -0500 2008    files: 0
  # Mon Aug 11 09:05:34 -0500 2008    files: 100000 => so, 1M files/hr. not good.
  def index_from_listing
    make_listing_file
    self.ripped_files
    FileUtils.cd path_to(:ripd_root) do
      File.foreach(listing_filename) do |full_path|
        track_count :files
        full_path.chomp!
        ripd_path = full_path[1+url.as_path.length..-1]
        next if ripd_path.blank?
        RippedFile.from_file(self, full_path, ripd_path)
      end
    end
    self.save
  end
end

#
# Index the raw files retrieved from website
#
class RippedFile
  include DataMapper::Resource
  property      :id,                    Integer,   :serial => true
  property      :ripped_file_collection_id, Integer,                 :unique_index => :ripd_path
  property      :ripd_path,             String,    :length => 255, :nullable => false, :unique_index => :ripd_path
  property      :retrieval_date,        DateTime
  property      :compressed_size,       Integer
  belongs_to    :ripped_file_collection

  def self.from_file clxn, full_path, ripd_path
    filedate = File.mtime(full_path)
    filesize = File.size( full_path)
    ripped_file = self.find_or_create({ :ripd_path => ripd_path }, {
      :ripped_file_collection => clxn,
      :retrieval_date  => filedate,
      :compressed_size => filesize,
    })
    ripped_file
  end

end

# SELECT r.*, u.host, u.path FROM ripped_files r
# LEFT JOIN ripped_file_collections rfs ON r.ripped_file_collection_id = rfs.id
# LEFT JOIN dm_uris u ON rfs.url_id = u.id
