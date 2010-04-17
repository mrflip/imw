
#
# Gem Crap
#
# copied from activewarehouse-etl gem

# PKG_BUILD       = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
# PKG_NAME        = 'imw'
# PKG_VERSION     = IMWcfg::VERSION::STRING + PKG_BUILD
# PKG_FILE_NAME   = "#{PKG_NAME}-#{PKG_VERSION}"
# PKG_DESTINATION = ENV["PKG_DESTINATION"] || "../#{PKG_NAME}"
# 
# RELEASE_NAME  = "REL #{PKG_VERSION}"
# 
# # RUBY_FORGE_PROJECT = ""
# # RUBY_FORGE_PKG     = PKG_NAME
# # RUBY_FORGE_USER    = ""
# 
# PKG_FILES = FileList[
#   'CHANGELOG',
#   'LICENSE',
#   'README*',
#   'TODO',
#   'Rakefile',
#   'bin/**/*',
#   'config/**/*',
#   'db/**/*',
#   'doc/**/*',
#   'etc/**/*',
#   'lib/**/*',
# ] - [ 'test' ]
# 
# 
# spec = Gem::Specification.new do |s|
#   s.name = '#{RUBY_FORGE_PROJECT}-#{RUBY_FORGE_PKG}'
#   s.version = PKG_VERSION
#   s.summary = "Transform disparate messy data sources into uniform open formats"
#   s.description = <<-EOF
#     Infinite Monkeywrench is a frameworks for extracting data from anywhere, in
#     any form, and converting it to structured, semantic data in open formats
#   EOF
# 
#   s.add_dependency('rake',                '>= 0.7.1')
#   s.add_dependency('activesupport',       '>= 1.3.1')
#   s.add_dependency('activerecord',        '>= 1.14.4')
#   s.add_dependency('fastercsv',           '>= 1.2.0')
# 
#   s.rdoc_options << '--exclude' << '.'
#   s.has_rdoc = false
# 
#   s.files = PKG_FILES.to_a.delete_if {|f| f.include?('.svn') || f.include?('.bzr') || f.include?('.git')}
#   s.require_path = 'lib'
# 
#   s.bindir = "bin" # Use these for applications.
#   s.executables = ['imw']
#   s.default_executable = "imw"
# 
#   s.author            = "Infochimps.org Coders (Philip flip Kromer and Dhruv Bansal)"
#   s.email             = "coders@infochimps.org"
#   s.homepage          = "http://infinitemonkeywrench.org/"
#   s.rubyforge_project = "imw"
# end
# 
# Rake::GemPackageTask.new(spec) do |pkg|
#   pkg.gem_spec = spec
#   pkg.need_tar = true
#   pkg.need_zip = true
# end
# 
# desc "Publish the release files to RubyForge."
# task :release => [ :package ] do
#   `rubyforge login`
# 
#   for ext in %w( gem tgz zip )
#     release_command = "rubyforge add_release #{RUBY_FORGE_PROJECT} #{PKG_NAME} 'REL #{PKG_VERSION}' pkg/#{PKG_NAME}-#{PKG_VERSION}.#{ext}"
#     puts release_command
#     system(release_command)
#   end
# end
# 
# desc "Publish the API documentation"
# task :pdoc => [:rdoc] do 
#   Rake::SshDirPublisher.new(RUBY_FORGE_USER, "/var/www/gforge-projects/#{RUBY_FORGE_PROJECT}/#{RUBY_FORGE_PKG}/rdoc", "rdoc").upload
# end
# 
# desc "Reinstall the gem from a local package copy"
# task :reinstall => [:package] do
#   windows = RUBY_PLATFORM =~ /mswin/
#   sudo = windows ? '' : 'sudo'
#   gem = windows ? 'gem.bat' : 'gem'
#   `#{sudo} #{gem} uninstall -x -i #{PKG_NAME}`
#   `#{sudo} #{gem} install pkg/#{PKG_NAME}-#{PKG_VERSION}`
# end
