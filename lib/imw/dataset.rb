
require 'YAML'

module IMW
  class DataSet
    attr_accessor :data

    def initialize data
      self.data = data
    end

    def self.from_yaml_file file_name, &block
      data = YAML.load(File.open(file_name))
      data = block.call data
      self.new(data)
    end

  end
end
