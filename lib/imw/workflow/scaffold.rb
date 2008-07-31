require 'imw/utils/paths'
require 'fileutils'
include FileUtils

module IMW

  def scaffold_script_dirs *dset_path
    add_path :me, [:scripts_root, dset_path]
    mkdir_p path_to(:me)
  end

  #
  # * creates a directory for the dataset in each of the top-level hierarchies
  #   (as given in ~/.imwrc)
  # * links to that directory within the working directory
  #   in directory pool/foo/bar/baz we'd find
  #     rawd => /data/rawd/foo/bar/baz
  #
  def scaffold_dataset_dirs *dset_path
    scaffold_script_dirs *dset_path
    [:rawd, :temp, :fixd, :log].each do |dir|
      dir_root = (dir.to_s + '_root').to_sym
      add_path dir, [:me, dir.to_s]
      mkdir_p path_to(dir_root, dset_path)
      ln_s    path_to(dir_root, dset_path), path_to(dir) unless File.exist?(path_to(dir))
    end
  end


  #
  # * creates a symlink within the working directory to the
  #   ripped directory, named after its url
  #
  def scaffold_rip_dir url
    dir      = :ripd
    dir_root = :ripd_root
    add_path dir, [:me, dir.to_s]
    mkdir_p path_to(dir_root, url)
    ln_s    path_to(dir_root, url), path_to(dir) unless File.exist?(path_to(dir))
  end

  def scaffold_dataset *dset_path
    scaffold_dataset_dirs *dset_path
  end

end
