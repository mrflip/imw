require 'dbi'
module IMW
  module Rip
    # Default values used for making a database connection.
    DEFAULT_CONNECTION = {
      :type     => :mysql,
      :host     => "localhost",
      :user     => ENV['USER'],
      :password => '',
      :database => nil
    }

    # Mappings between database programs and DBI strings.
    DBI_DRIVERS = {
      :mysql    => 'DBI:MySQL',
      :odbc     => 'DBI:ODBC',
      :oracle   => 'DBI:OCI8',
      :postgres => 'DBI:Pg',
      :sqlite   => 'DBI:SQLite',
      :sqlite3  => 'DBI:SQLite3'
    }
      
    private
    def self.run_query type,host,user,password,database,query,options = {}, &block
      connection = DBI.connect "#{DBI_DRIVERS[type]}:#{database}", user, password
      resultset = connection.execute(query)
      
      if options[:into] then
        outfile = IMW.open(options[:into],'w')
        outfile.dump(resultset.fetch_all)
      elsif block
        resultset.fetch {|row| yield row }
      else
        resultset.fetch_all
      end
    end

    def self.print_params type, host, user, password, database, query, options
      <<EOF
  database type: #{type}
  host:          #{host}
  user:          #{user}
  password:      #{password}
  database:      #{database}
  query:         #{query}
  options:       #{options.inspect}
EOF
    end
    public

    # Run a query against a database.  If passed a block then iterate
    # over the rows of the result set, otherwise just return the
    # resultset.
    #
    # [<tt>:adaptor</tt> or <tt>:driver</tt> or <tt>type</tt>] database server type (see <tt>DBI_DRIVERS</tt>)
    # [<tt>:at</tt> or <tt>:host</tt>] database server to connect to
    # [<tt>:as</tt> or <tt>:user</tt>] username to connect as
    # [<tt>:identified_by</tt> or <tt>:password</tt>] password to use
    # [<tt>:named</tt> or <tt>:database</tt>] database to use
    # [<tt>:query</tt>] query string to run
    # [<tt>:select</tt>] query string to run (will add the word
    #                    +SELECT+ to the beginning of the query if
    #                    absent)
    # [<tt>:into</tt>] local file to select results into
    def self.from_database options = {}, &block
      type     = (options[:type]     or options[:adaptor]       or DEFAULT_CONNECTION[:type])
      host     = (options[:host]     or options[:at]            or DEFAULT_CONNECTION[:host])
      user     = (options[:user]     or options[:as]            or DEFAULT_CONNECTION[:user])
      password = (options[:password] or options[:identified_by] or DEFAULT_CONNECTION[:password])
      database = (options[:database] or options[:named]         or DEFAULT_CONNECTION[:database])

      if options[:select] then
        query = options[:select]
        query = "SELECT " + query unless query =~ /^ *SELECT/
      else
        query = options[:query]
      end

      raise ArgumentError.new("Not enough information to run query:\n#{self.print_params(type,host,user,password,database,query,options)}") unless type && host && user && password && database && query
      if block then
        self.run_query(type, host, user, password, database, query, options) {|row| yield row }
      else
        self.run_query type, host, user, password, database, query, options
      end
    end
  end
end

      
