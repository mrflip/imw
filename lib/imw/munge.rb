# ===========================================================================
#
# DatasetMunger
# Defines the ripd => rawd => fixd workflow
#
# FIXME -- find out how to subclass task to do some housekeeping
# automagically.

unless defined?(FasterCSV)
  gem 'fastercsv'
  require 'faster_csv'
end


class IMW < OpenStruct

  #
  # 
  # 
  def ls(dir, patt)
    $imw.rips.map do |rip| 
      FileList[$imw.path_to(dir, patt)].to_a
    end.sum()
  end

  # make_uniqid_contributor(contributor)
  #
  # if there's a :url, turn it into the form
  #   tld.domain.blah.blah/root/path
  #  That is: reverse the dotted parts of the URL and append the path.
  #  we kill off a leading www. but leave any other tertiary dns part. 
  #
  # If not, then just uniqid'ize the :name.
  #
  # else raise error
  #
  def make_uniqid_contributor(contributor)
    return contributor.url
  end
  
end
