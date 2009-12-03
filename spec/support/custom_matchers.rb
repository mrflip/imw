module CustomMatchers
  def contain *paths
    paths = paths.flatten
    simple_matcher("contain #{paths.inspect}") do |given, matcher|
      given_contents = Dir[given + "/**/*"].map do |abs_path|
        abs_path[(given.length + 1)..-1]
      end
      matcher.failure_message = "expected #{given} to contain #{paths.inspect}, instead it contained #{given_contents.inspect}"
      matcher.negative_failure_message = "expected #{given} not to contain #{paths.inspect}"
      paths.all? { |path| given_contents.include?(path) }
    end
  end
end
