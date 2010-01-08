require 'imw'
require 'optparse'

module IMW

  RunnerError = Class.new(IMW::Error)
  
  class Runner

    DEFAULT_OPTIONS = {
      :requires => [],
      :dry_run  => false
    }

    attr_reader :args, :options

    def initialize *args
      @args    = args
      @options = DEFAULT_OPTIONS.dup
      parser.parse!(args)       # will trim options from args
    end

    def parser
      OptionParser.new do |opts|
        opts.banner = "usage: imw [OPTIONS] ACTION [DATASET_SELECTOR...]"
        
        opts.separator ''
        
        opts.on('-r', '--require PATH', "Require Ruby file at PATH (recursively if PATH is a directory)") do |path|
          options[:requires] << path
        end

        opts.on('-d', '--dry-run', "Run but do not do anything.") do
          options[:dry_run] = true
        end
        
      end
    end

    def process_imw_files
      Dir['*.imw'].each { |path| load File.expand_path(path) }
    end

    def process_required_files
      options[:requires].each do |requireable|
        requireable = IMW.open(requireable)
        if requireable.directory?
          requireable["*.rb"].each { |path| require path }
        else
          require requireable.path
        end
      end
    end

    def action
      args.first && args.first.to_sym
    end

    def selector_regexps
      args[1..-1].map { |selector| Regexp.new(selector) }
    end

    def dataset_handles
      handles = Set.new
      if selector_regexps.blank?
        # when invoked without a selector regexp, only assume a
        # dataset if the repository has a single dataset
        handles.add IMW::REPOSITORY.first.first if IMW::REPOSITORY.size == 1
      else
        keys = IMW::REPOSITORY.keys
        unless keys.empty?
          selector_regexps.map do |regexp|
            handles += keys.find_all { |key| key =~ regexp }
          end
        end
      end
      handles.to_a.sort
    end

    def datasets
      dataset_handles.map { |handle| IMW::REPOSITORY[handle] }
    end

    def take_action!
      case 
      when action == :list then
        puts dataset_handles
      when IMW::Workflow::STEPS.include?(action) then
        datasets.each do |dataset|
          dataset[action].execute
        end
      else
        puts parser
      end
    end

    def run!
      process_imw_files
      process_required_files
      take_action!
      return 0
    end
  end
end

