IMW_ROOT_DIR = File.join(File.dirname(__FILE__), '..') unless defined? IMW_ROOT_DIR
IMW_SPEC_DIR = File.join(IMW_ROOT_DIR, 'spec')         unless defined? IMW_SPEC_DIR
IMW_LIB_DIR  = File.join(IMW_ROOT_DIR, 'lib')          unless defined? IMW_LIB_DIR
$: << IMW_LIB_DIR

require 'rubygems'
require 'spec'
require 'fileutils'
require 'imw/utils'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |path| require path }

module IMWTest
  TMP_DIR = "/tmp/imwtest"
  
end


Spec::Runner.configure do |config|
  config.after(:each) do
    
  end
  

