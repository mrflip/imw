#!/usr/bin/env ruby

module IMW
  def self.paths() @@paths  end
  @@paths = { 
    :home    => ENV['HOME'],
    :imw_root => File.join(File.dirname(__FILE__), '..'),
    :imw_bin => [:imw_root, 'bin'],
    :imw_etc => [:imw_root, 'etc'],
    :imw_lib => [:imw_root, 'lib'],
    :data    => [:home, 'data'],
    :ripd    => [:data, 'ripd'],
    :rawd    => [:data, 'rawd'],
    :temp    => [:data, 'temp'],
    :fixd    => [:data, 'fixd'],
    :pkgd    => [:data, 'pkgd'],
    :log     => [:data, 'log'],
    :foo     => [:temp, :data, :home, :imw_lib]
  }
  
end
