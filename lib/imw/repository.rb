require 'imw/utils'

module IMW

  # A Repository is a collection of datasets.
  class Repository < Hash

    # FIXME This should read some configuration settings somewhere and
    # generate a pool specific to each IMW user.
    def self.default
      new
    end

  end

  # The default repository managed by IMW.  
  REPOSITORY = Repository.default
  
  # Add a dataset to the IMW::REPOSITORY.  If the dataset has a
  # +handle+ then it will be used as the key in this repository;
  # otherwise the dataset's class will be used.
  def self.add dataset
    REPOSITORY[dataset.handle] = dataset
  end

  # Remove a dataset from the IMW::REPOSITORY.  Can pass in either a
  # string handle or an instance of the dataset.
  def self.delete handle
    handle = handle.handle if handle.respond_to?(:handle)
    REPOSITORY.delete(handle)
  end

end


