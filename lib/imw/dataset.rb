require 'imw/dataset/stats'
require 'imw/dataset/loaddump'

module IMW
  class DataSet
    include Enumerable

    attr_accessor :data
    def initialize data
      self.data = data
    end

    def method_missing(method, *args, &block)
      data.send(method, *args, &block)
    end

  end
end
