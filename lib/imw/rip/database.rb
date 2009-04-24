
require 'dbi'


module IMW

  module Rip

    
    # Default values used for making a database connection.
    DEFAULT_DATABASE_CONNECTION = {
      :type     => :mysql,
      :host     => "localhost",
      :user     => ENV['USER'],
      :password => '',
      :database => nil
    }

    # Run a query against a database and write the result set to a file 
    def self.from_database options = {}
      options.reverse_merge!({
                               :at            => DEFAULT_DATABASE_CONNECTION[:host],
                               :as            => DEFAULT_DATABASE_CONNECTION[:user],
                               :identified_by => DEFAULT_DATABASE_CONNECTION[:password]
                             })
    end
  end
end

      
