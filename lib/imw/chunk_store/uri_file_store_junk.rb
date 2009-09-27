
  # ===========================================================================
  #
  # ID, naming, etc
  #
  def normalize_url!
    u = Addressable::URI.parse(self.full_url).normalize
    self.full_url = u.to_s
  end

  # ===========================================================================
  #
  # Properly belongs in FileStore module
  #
  #
  # Refresh cached properties from our copy of the asset.
  #
  def update_from_file!
    self.make_uuid_and_handle # make sure this happened
    # Set the file path
    self.file_path = self.to_file_path if self.file_path.blank?
    # FIXME -- kludge to ripd_root
    if ! File.exist?(actual_path)
      self.fetched   = false
    else
      self.fetched   = self.tried_fetch = true
      self.file_size = File.size( actual_path)
      self.file_time = File.mtime(actual_path)
    end
    self.fetched
  end
  def actual_path
    path_to(:ripd_root, self.file_path)
  end

  #
  #
  #
  def contents options={}
    wget options
    if fetched
      File.open actual_path
    end
  end
