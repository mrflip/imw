require 'imw/dataset/datamapper'

module IMW::SpecConfig

  def self.setup_datamapper_test_db
    IMW::DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({
        :dbname => 'imw_dataset_datamapper_test' })
    DataMapper.auto_migrate!
  end

end
