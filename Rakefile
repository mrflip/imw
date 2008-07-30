#
# h2. Rakefile -- master rakefile for imw
#
# == About
#
# This is the master Rakefile for the Infinite Monkeywrench.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

# This task is for running Nick Sieger's "autotest rspec
# plugin"[http://blog.nicksieger.com/articles/2007/01/30/rspec-autotest-for-standalone-projects].
namespace :spec do
  task :autotest do
    require './spec/rspec_autotest'
    RspecAutotest.run
  end
end

# puts "#{File.basename(__FILE__)}: Line 'em up and knock 'em down." # at bottom
