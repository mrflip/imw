#
# h2. imw/foo -- desc lib
#
# action::    desc action     
#
# == About
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

# Standard libraries
require 'rubygems'
require 'logger'
require 'yaml'
# require 'fileutils'
require 'ostruct'

# Push this directory to front of ruby lib path
$:.unshift(File.dirname(__FILE__))

# Load gems (snippet stolen from active_warehouse gem)
unless Kernel.respond_to?(:gem)
  Kernel.send :alias_method, :gem, :require_gem
end
unless defined?(Rake)         
  gem 'rake'
  require 'rake'
end
unless defined?(ActiveSupport)
  gem 'activesupport'
  require 'active_support'
end
unless defined?(ActiveRecord)
  # active_support has many warnings.
  old_verbosity = $VERBOSE; $VERBOSE = false
  gem 'activerecord'
  require 'active_record'
  $VERBOSE = old_verbosity
end

# Load imw files
require 'imw/utils/version'
require 'imw/utils/core_extensions'

module IMWConfig
  # load config files
  config_files = [
    File.join(File.dirname(__FILE__), '../etc/imw_main_config.yaml'),
    File.join(File.dirname(__FILE__), '../etc/imw_site_config.yaml'),
  ]
  Config = { }
  config_files.map{ |f| YAML.load(File.open(f)) }.each do |cfg|
    Config.deep_merge!(cfg) unless cfg.blank?
  end
  # Hold identifiers under this amount
  IDMaxlen = 80
end

# Home base for all activity


require 'imw/model'         # collection, dataset, field, contributor, ...
require 'imw/workflow/imw_paths'

# Note the capitalization on the class name -- else it's a constant
class IMW < OpenStruct
  include IMWPaths

  #
  # define a pool to sit in the given category/subcategory/pool
  #
  def initialize (cat, subcat, pool, hsh = { })
    super(hsh)
    self.cat, self.subcat, self.pool = cat, subcat, pool
    self.init_paths(cat, subcat, pool)
  end 

  #
  # Guess the pool path from the first defined among
  # * pool_path_in  argument
  # * $pool         environment variable
  # * otherwise, the current working directory
  #
  def IMW.new_from_env(pool_path_in=nil, hsh={})
    pool_path_in  ||= ENV['pool'] || ENV['PWD']
    pool_path_grokd = IMWPaths.grok_path(pool_path_in)
    raise ArgumentError.new("Couldn't understand path #{pool_path_in}") if !pool_path_grokd
    self.new(* (pool_path_grokd.values_at(:cat, :subcat, :pool)+[hsh]) )
  end
end

# puts "#{File.basename(__FILE__)}: You wield your Infinite Monkeywrench. Formidable!" 
