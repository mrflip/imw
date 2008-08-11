IMW_ROOT_DIR = File.join(File.dirname(__FILE__), '..') unless defined? IMW_ROOT_DIR
IMW_SPEC_DIR = File.join(IMW_ROOT_DIR, 'spec')         unless defined? IMW_SPEC_DIR
IMW_LIB_DIR  = File.join(IMW_ROOT_DIR, 'lib')          unless defined? IMW_LIB_DIR
$: << IMW_LIB_DIR

require 'rubygems'
require 'spec'
require 'imw/utils'


module IMW::SpecConfig
  SKIP_ARCHIVE_FORMATS = [:rar]

  TEST_WITH_DATAMAPPER = false

end unless defined? IMW::SpecConfig


