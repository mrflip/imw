require 'rubygems'
require 'rake'

begin
  # http://github.com/technicalpickles/jeweler
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "imw"
    gem.summary = "The Infinite Monkeywrench (IMW) makes acquiring, extracting, transforming, loading, and packaging data easy."
    gem.description = "The Infinite Monkeywrench (IMW) is a Ruby frameworks to simplify the tasks of acquiring, extracting, transforming, loading, and packaging data. It minimizes programmer time by encapsulating common data workflows and patterns and creating interfaces to many other useful Ruby libraries."
    gem.email = "coders@infochimps.org"
    gem.homepage = "http://github.com/infochimps/imw"
    gem.authors = ["Dhruv Bansal", "Philip (flip) Kromer"]
    
    gem.files.exclude "old/**/*"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available.  Install it with: sudo gem install jeweler"
end
