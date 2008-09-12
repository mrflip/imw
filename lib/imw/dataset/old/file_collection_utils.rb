#!/usr/bin/env ruby
require 'imw/utils'; include IMW
require 'imw/dataset/file_collection'
require 'tempfile'

def bulk_listing_filename()     '/tmp/listing_foo.txt'  end
def table_name()                'ripped_files'          end

def run_mysql_cmd db_params, cmd
  username, password, hostname, dbname = db_params.values_at(:username, :password, :hostname, :dbname)
  query_file = Tempfile.new("qlstg")
  query_file.puts cmd
  query_file.close
  puts `time mysql -E -u#{username} -p#{password} -h#{hostname} #{dbname} < #{query_file.path}`
end

def bulk_load_mysql db_params, ripd_base
  announce "Calling mysql to bulk load #{ripd_base} (expect ~2s per 100k files)"
  run_mysql_cmd db_params, %Q{
    LOAD DATA LOCAL INFILE '#{bulk_listing_filename}'
      REPLACE INTO TABLE `#{table_name}`
      FIELDS TERMINATED BY ','
      LINES  TERMINATED BY '\n'
      (`ripped_file_collection_id`, `ripd_path`, `retrieval_date`, `compressed_size`)
      ;
  }
end

def clear_table
  run_mysql_cmd "TRUNCATE #{table_name}"
end

class RippedFileCollection
  def bulk_load_listing db_params, extra_find_args=""
    announce "Indexing #{url.as_path} (expect ~10s per 100k files)"
    FileUtils.cd path_to(:ripd_root) do
      find_fmt = "#{self.id},%P,%TY-%Tm-%Td %TH:%TM:%TS,%s\n"
      find_cmd = "find #{url.as_path} #{extra_find_args} -printf '#{find_fmt}' > #{bulk_listing_filename}"
      puts `time #{find_cmd}`
    end unless File.exist?(bulk_listing_filename)
    bulk_load_mysql db_params, url.as_path
  end
end


# SELECT rf_yrs.*, dfc.*, url.scheme, url.host, url.path
#   FROM (
#     SELECT SUBSTR(ripd_path,1,4) AS yr, COUNT(*), r.*
#     FROM ripped_files r
#     GROUP BY ripped_file_collection_id, yr
#     ORDER BY ripped_file_collection_id, yr
#   ) rf_yrs
#   LEFT JOIN ripped_file_collections  rfc ON rfc.id = rf_yrs.ripped_file_collection_id
#   LEFT JOIN dataset_file_collections dfc ON dfc.id = rfc.dataset_file_collection_id
#   LEFT JOIN dm_uris url ON url.id = rfc.url_id

db_params = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_weather_ncdc' })
IMW::Dataset.setup_remote_connection db_params

# Daily
daily_dset_clxn  = DatasetFileCollection.find_or_create({ :category => 'weather/ncdc/daily' })
rf_clxn          = RippedFileCollection.find_or_create_from_url 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod', daily_dset_clxn
rf_clxn.bulk_load_listing db_params
# Hourly
hourly_dset_clxn = DatasetFileCollection.find_or_create({ :category => 'weather/ncdc/hourly' })
rf_clxn          = RippedFileCollection.find_or_create_from_url 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa', hourly_dset_clxn
rf_clxn.bulk_load_listing db_params, '\\! \\( -iname "isd-lite" -prune \\) '
# Hourly-lite
hlite_dset_clxn  = DatasetFileCollection.find_or_create({ :category => 'weather/ncdc/hourly_lite' })
rf_clxn          = RippedFileCollection.find_or_create_from_url 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite', hlite_dset_clxn
rf_clxn.bulk_load_listing db_params
