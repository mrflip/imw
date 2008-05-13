require 'yaml'

def identify(obj)
  obj.hash
end

#
#  
def announce(*args)
    $stderr.puts "%s: %s" % [Time.now, args.flatten.map(&:to_s).join("\t")]
end

# puts "Your monkeywrench suddenly feels more utilisable"
