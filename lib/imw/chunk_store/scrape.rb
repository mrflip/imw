
module IMW
  #
  #
  # You're responsible for defining class methods
  #  ripd_file -- the location for the scraped file
  #  rip_uri  -- the uri to fetch.
  #
  module ScrapeFile
    WGET_COMMAND = 'wget'
    #
    # wget options
    #
    # Crudely scrape a uri.
    #
    # Options:
    #
    # * :http_user, :http_passwd -- HTTP Basic Auth username and password.
    #   These are passed to wget on the command line, a security risk
    #   if you are in an untrusted environment.
    #
    # * :sleep_time -- Amount to sleep after a request.  If the file is not
    #   requested the method (for instance, if it exists) does not sleep.
    #
    # * :log_level -- verbosity
    #
    def wget options={ }
      options = options.reverse_merge :sleep_time => 1, :log_level => Logger::DEBUG
      if should_fetch?
        mkdir_p File.dirname(ripd_file), :verbose => false
        @exists = nil
        system(WGET_COMMAND, *wget_command_args(options))
        self.result_status = $?.to_i
        IMW.log.add(options[:log_level], "Sleeping #{options[:sleep_time]}") unless options[:sleep_time] == 0
        sleep options[:sleep_time]
      else
        self.result_status = 0
        IMW.log.add(options[:log_level], "Skipping #{rip_uri}")
      end
      return (self.result_status == 0) && is_healthy?
    end

    #
    # Construct the wget command line from options and file.
    #
    def wget_command_args options
      cmd = []
      cmd << "--no-verbose"
      cmd << "--timeout=8"
      cmd << "--tries=1"
      cmd << "--http-user=#{options[:http_user]}"     if options[:http_user]
      cmd << "--http-passwd=#{options[:http_passwd]}" if options[:http_passwd]
      cmd << "-O#{ripd_file}"
      cmd << "#{rip_uri}"
    end

    #
    # Decide if the asset should be fetched.  Currently just checks if the file
    # exists (returns false if it exists) but among other things you could
    # override to set an expiry or recurring schedule
    def should_fetch?
      ! exists?
    end

    #
    # Check if the asset exists on disk.  It might be a placeholder, though: see
    # #is_healthy?
    #
    def exists?
      return @exists unless @exists.nil?
      @exists = File.exists?(ripd_file)
    end

    #
    # Checks if the file exists and is not a placeholder (0-byte file)
    #
    # Is the race condition here worth worrying about?
    #
    def is_healthy?
      exists? && File.size(ripd_file) != 0
    end

    # insert accessors for result status
    def self.included base
      base.class_eval do
        attr_accessor :result_status
      end
    end
  end
end

    #
    # * :leave_turd -- leave a 0-byte turd on failure; this makes it
    #   easy to avoid re-requesting a file.
    #   Use find ripd/ -size 0 --exec rm {} \; to scrub
    #
    # # Matches error message from wget
    # WGET_ERROR_RE = / ERROR (\d+): /
    # #
    # # Clumsily check wget's output for error status
    # #
    # def check_wget_outcome! result
    #   p result
    #   result_text = result.to_s
    #   if m = WGET_ERROR_RE.match(result_text)
    #     self.error_code = m.captures.first
    #     self.error_text = result_text
    #   else
    #     self.error_code = self.error_text = nil
    #   end
    #   p [self, result_text]
    # end
