require 'imw'
require 'optparse'

module IMW

  RunnerError = Class.new(IMW::Error)
  
  class Runner

    DEFAULT_OPTIONS = {
      :requires  => [],
      :selectors => [],
      :dry_run   => false
    }

    attr_reader :args, :options

    def initialize *args
      @args    = args
      @options = DEFAULT_OPTIONS.dup
      parser.parse!(args)       # will trim options from args
    end

    def parser
      OptionParser.new do |opts|
        opts.banner = "usage: imw [OPTIONS] TASK"
        opts.separator <<EOF

  Run TASK for all datasets in the repository.  IMW will read any
  *.imw files in the current directory by default.

  Options include

EOF

        opts.on('-l', '--list', "List datasets in repository") do
          options[:list] = true
        end

        opts.on('-s', '--selector SELECTOR', "Filter datasets by regexp SELECTOR.  Can be given more than once.") do |selector|
          options[:selectors] << selector
        end
        
        opts.on('-r', '--require PATH', "Require PATH.  Can be given more than once.") do |path|
          options[:requires] << path
        end

      end
    end

    def require_files
      Dir['*.imw'].each { |path| load File.expand_path(path) }      
      options[:requires].each do |path|
        IMW.open(path) do |requireable|
          if requireable.directory?
            requireable["**/*.rb"].each  { |file| require file }
            requireable["**/*.imw"].each { |file| load    file }
          else
            require requireable.path
          end
        end
      end
    end

    def task
      args.first
    end

    def handles
      matched_handles = Set.new
      if options[:selectors].blank?
        matched_handles += IMW::REPOSITORY.keys
      else
        keys = IMW::REPOSITORY.keys
        unless keys.empty?
          options[:selectors].each do |selector|
            matched_handles += keys.find_all { |key| key =~ Regexp.new(selector) }
          end
        end
      end
      matched_handles.to_a.sort
    end

    def datasets
      handles.map { |handle| IMW::REPOSITORY[handle] }
    end

    def list!
      puts handles
      exit
    end

    def run_task!
      datasets.each do |dataset|
        dataset[task].invoke
      end
      exit
    end
      
    def run!
      require_files
      case
      when options[:list]
        list!
      when task.blank?
        puts parser
        exit 1
      else
        run_task!
      end
    end
  end
end

