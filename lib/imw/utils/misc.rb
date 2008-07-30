#
# h2. lib/imw/utils/misc.rb -- miscellaneous functions
#
# == About
#
# A collection of helpful functions in various places through the IMW
# source tree.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

def identify(obj)
  obj.hash
end

def announce(*args)
    $stderr.puts "%s: %s" % [Time.now, args.flatten.map(&:to_s).join("\t")]
end

# puts "#{File.basename(__FILE__)}: Your Monkeywrench seems suddenly more utilisable." # at bottom
