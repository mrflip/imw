class Array
  def random
    self[rand(length)]
  end
end

class Hash
  # Stolen from ActiveSupport::CoreExtensions::Hash::ReverseMerge.
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  # Stolen from ActiveSupport::CoreExtensions::Hash::ReverseMerge.
  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end
end

