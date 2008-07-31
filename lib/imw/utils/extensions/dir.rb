#
# h2. lib/imw/utils/extensions/dir.rb -- directory extensions
#
# == About
#
# The Ruby +Dir+ module is rubbish.  Time to clean it up a bit!
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 


class Dir

  # Return the absolute paths of files and directories in the
  # directory, leaving out `.' and `..' entries.
  def abs_contents
    contents = []
    self.entries.each {|entry| contents << self.path + '/' + entry unless entry == '.' || entry == '..'}
    contents
  end
end


# puts "#{File.basename(__FILE__)}: You open the folder and see along list of names.  Some have been crossed out -- ominously..." # at bottom
