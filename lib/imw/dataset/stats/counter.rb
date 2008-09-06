module IMW
  class RecordCounter < Hash
    def record val
      self[val] ||= 0
      self[val]  += 1
    end

    def if_seen val, &block
      if self[val]
        yield
      end
      record val
    end

    def unless_seen val, &block
      unless self[val]
        yield
      end
      record val
    end

  end
end
