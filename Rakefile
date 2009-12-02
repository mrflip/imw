require 'rubygems'
require 'rake'

begin
  # http://github.com/technicalpickles/jeweler
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "imw"
    gem.summary = "The Infinite Monkeywrench (IMW) makes acquiring, extracting, transforming, loading, and packaging data easy."
    gem.email = "coders@infochimps.org"
    gem.homepage = "http://github.com/infochimps/imw"
    gem.authors = ["Dhruv Bansal", "Philip (flip) Kromer"]
    
    gem.files.exclude "old/**/*"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available.  Install it with: sudo gem install jeweler"
end
