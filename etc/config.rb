#
# h2. etc/config.rb -- configuration settings for imw
#
# == About
#
# This is a (hopefully) temporary Ruby configuration file containing
# settings for this IMW installation.  It will eventually be replaced
# with a YAML file which will be parsed by IMW.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

module IMW

  # Paths to external utilities
  EXTERNAL_PROGRAMS = {
    :tar => "tar"
    :rar => "rar"
    :zip => "zip"
    :unzip => "unzip"
    :gzip => "gzip"
    :bzip2 => "bzip2"
  }
  
end

# puts "#{File.basename(__FILE__)}: Those who fail to care for their wrenches are doomed to turn nuts." # at bottom
