#
# h2. lib/imw/utils/boot.rb -- startup functions
#
# == About
#
# This file contains code necessary to boot the Infinite Monkeywrench
# at a particular site.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#

require 'yaml'

# Checks that dependencies on Ruby gems and external programs are
# satisfied
#
# FIXME needs to be written!
def check_dependencies()
  true
end

# Returns the root of the IMW file hierarchy
#
# This root is determined by the 'IMW_ROOT' environment variable or
# by the "root" entry in the etc/directories.yaml configuration file,
# in that order.
def imw_root()
  # first look at environment variable 'IMW_ROOT'
  if ENV['IMW_ROOT']
    imw_root = ENV['IMW_ROOT']
  else
    # try to read the configuration files
    begin
      config = YAML::load_file(File.expand_path("#{File.dirname(__FILE__)}/../../../etc/directories.yaml"))
    rescue Errno::ENOENT
      
    
    
  
  
  $IMW_ROOT ||= ENV['IMW_ROOT'] || File.expand_path(IMW::Config['imw_root'])
  if !$IMW_ROOT 
    warn "With no $IMW_ROOT variable your infinite monkeywrench is confused, driftless. Setting an $IMW_ROOT environment variable will give it a firm fulcrum on which to act." 
  end
  if !File.exist? $IMW_ROOT then 
    warn "The $IMW_ROOT directory '#{$IMW_ROOT}' doesn't exist. This may cause distress and confusion." 
  end
  if !File.is_directory? $IMW_ROOT then
    warn "The $IMW_ROOT directory '#{$IMW_ROOT}' is not a directory."
  end
end


# puts "#{File.basename(__FILE__)}: You heft up your Infinite Monkeywrench for the first time and marvel at how so much power could be made so wondrous light!" # at bottom
