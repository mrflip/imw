#!/usr/bin/env ruby

module IMW
  @@paths = {
    :home      => ENV['HOME'],
    :imw_root  => File.join(File.dirname(__FILE__), '..'),

    # Data processing scripts
    :scripts_root => [:home, 'ics', 'pool'],

    # the imw library
    :imw_bin   => [:imw_root, 'bin'],
    :imw_etc   => [:imw_root, 'etc'],
    :imw_lib   => [:imw_root, 'lib'],

    # Data
    :data_root => [:home,      'data'],
    :ripd_root => [:data_root, 'ripd'],
    :rawd_root => [:data_root, 'rawd'],
    :temp_root => [:data_root, 'temp'],
    :fixd_root => [:data_root, 'fixd'],
    :pkgd_root => [:data_root, 'pkgd'],
    :log_root  => [:data_root, 'log'],
  }

end
