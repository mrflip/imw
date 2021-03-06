require 'imw/utils/extensions/hash'

module IMW
  module Config

    # Root of the IMW source base.
    def self.imw_root
      File.expand_path File.join(File.dirname(__FILE__), '../..')
    end

    #
    # User configuration file
    #
    # By default, the file ~/.imwrc (.imwrc, in your home directory --
    # note no .rb extension) is sourced at top level.  If the $IMWRC
    # environment variable is set, that file will be sourced instead.
    #
    # Any code within this file will override settings in
    # /etc/imwrc.rb which itself overrides IMW_ROOT/etc/imwrc.rb
    #
    USER_CONFIG_FILE = File.join(ENV['HOME'] || '', '.imwrc')
    # Environment variable to override user configuration file location.
    ENV_CONFIG_FILE = "IMWRC"
    def self.user_config_file # :nodoc:
      File.expand_path(ENV[ENV_CONFIG_FILE] || USER_CONFIG_FILE)
    end

    # Path to site-wide config file (overwrites IMW defaults but
    # overridden by user defaults).
    SITE_CONFIG_FILE = "/etc/imwrc.rb"
    def self.site_config_file # :nodoc:
      SITE_CONFIG_FILE
    end

    def self.default_config_file # :nodoc:
      File.join(imw_root, "etc/imwrc.rb")
    end
    
    # Source the config files
    def self.load_config
      if File.exist?(user_config_file)
        load user_config_file
      end

      if File.exist?(site_config_file)
        load site_config_file
      end

      load default_config_file
        
    end
  end
end

#
# Load the config files
#
IMW::Config.load_config

