require 'rubygems'
# gem     'dm-core'
require 'dm-core'

module IMW
  class DataSet
    # A MySQL 4.x+ connection:
    def self.setup_connection protocol, user, pass, host, dbname
      DataMapper.setup(:default, "%s://%s:%s@%s/%s" %[protocol, user, pass, host, dbname])
    end

  end
end
