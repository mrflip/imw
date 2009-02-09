module IMW
  include FileUtils

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
    [:rawd, :tmp, :fixd, :log].each do |seg|
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

end
