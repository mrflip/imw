#
# h2. lib/imw/workflow/scaffold.rb -- scaffold the directory structure for a dataset
#
# == About
#
# Defines workflow tasks for datasets to create directories and
# symlinks to ease the processing of a dataset.
#
# Right now this file contains code written by Flip as well as code
# written by Dhruv which accomplish basically the same task.  Dhruv's
# code integrates with <tt>IMW::Dataset</tt> and Rake and should be
# used preferentially.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
#
# puts "#{File.basename(__FILE__)}: POST NO BILLS.  Is that funny to anyone but me?  No?" # at bottom


require 'imw/utils'
require 'fileutils'
include FileUtils

module IMW

  ################################################################
  ## FLIP'S CODE
  ################################################################

  def scaffold_script_dirs
    mkdir_p path_to(:me)
  end

  #
  # * creates a directory for the dataset in each of the top-level hierarchies
  #   (as given in ~/.imwrc)
  # * links to that directory within the working directory
  #   in directory pool/foo/bar/baz we'd find
  #     rawd => /data/rawd/foo/bar/baz
  #
  def scaffold_dset_dirs
    [:rawd, :temp, :fixd, :log].each do |seg|
      unless File.exist?(path_to(seg))
        seg_dir = path_to(pathseg_root(seg), :dset)
        mkdir_p seg_dir
        ln_s    seg_dir, path_to(seg)
      end
    end
  end


  #
  # * creates a symlink within the working directory to the
  #   ripped directory, named after its url
  #
  def scaffold_rip_dir url
    unless File.exist?(path_to(seg))
      ripd_dir = path_to(:ripd_root, url)
      mkdir_p ripd_dir
      ln_s    ripd_dir, path_to(:ripd)
    end
  end

  def scaffold_dset
    scaffold_script_dirs
    scaffold_dset_dirs
  end


  ################################################################
  ## DHRUV's CODE -- uses IMW::Dataset and Rake
  ################################################################
  class Workflow

    # Creates a workflow task <tt>:scaffold</tt> to scaffold the
    # directory & symlink structure for this dataset.
    def scaffold_dirs

end
