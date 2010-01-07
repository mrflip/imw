
  def self.url_from_file_path fp
    # FIXME -- doesn't work with extension preservation
    unless m = (%r{\A([^/_]+)(_[^/]+)?/(?:(.*?)/)?([^/]*)-([a-f0-9]{30,32})\z}.match(fp)) then
      # m1 = %r{\A([^/_]+)(_[^/]+)?/(?:(.*?))-([a-f0-9]{28,})}i.match(fp);
      raise "Bad match to #{fp}"
    end
    fp_host, fp_scheme, fp_path, fp_file, fp_uuid, fp_ext = m.captures
    fp_host     = fp_host.split('.').reverse.join('.')
    fp_scheme ||= 'http'
    fp_path     = File.join(*[fp_path, fp_file].compact) # FIXME -- no ext
    url = Addressable::URI.new(fp_scheme, nil, nil, fp_host, nil, fp_path, nil, nil)
    unless m = (%r{\A([^/_]+)(_[^/]+)?/(?:(.*?)/)?([^/]*)-([a-f0-9]{32})\z}.match(fp)) then
      # warn "Bad luck!!! #{url.path} hash is #{fp_uuid} vs #{UUID.sha1_create(UUID_INFOCHIMPS_LINKS_NAMESPACE, url.to_s).hexdigest}"
    end
    url
  end

  #
  # returns [dirname, basename, ext] for the file_path
  # ext is determined by basename_ext_splitter
  #
  def path_split
    path_split_str path
  end

  # lowercase; only a-z, num, . -
  def scrubbed_revhost
    return unless revhost
    revhost.downcase.gsub(/[^a-z0-9\.\-]+/i, '')  # note: no _
  end

  cattr_accessor  :basename_ext_splitter
  BASENAME_EXT_SPLIT_SMART = /(.+?)\.(tar\.gz|tar\.bz2|[^\.]+)/
  BASENAME_EXT_NO_SPLIT    = /(.+?)()/
  self.basename_ext_splitter = BASENAME_EXT_NO_SPLIT

  #
  # Like File.split but heuristically handles things like .tar.bz2:
  #
  #   foo.        => ['foo.', '']
  #   foo.tar.gz  => ['foo.', '']
  #   foo.tar.bz2 => ['foo.', '']
  #   foo.yaml    => ['foo', '']
  #
  def path_split_str str
    if str =~ %r{/.+\z}
      dirname, basename = %r{\A(.*)/([^/]+)\z}.match(str).captures
    else
      dirname, basename = ['', str]
    end
    # Get basename, extension (as given by capture groups in basename_ext_splitter)
    if basename_ext_splitter && (m = /\A#{basename_ext_splitter}\z/i.match(basename))
      basename, ext = m.captures
    else
      basename, ext = [basename, '']
    end
    [dirname, basename, ext]
  end

  # remove all blank components, join the rest with separator
  def join_non_blank separator, *strs
    strs.reject(&:blank?).join(separator)
  end

  # only a-z A-Z, num, .-_/
  def scrubbed_path
    path_part = path
    # colons into /
    path_part = path_part.gsub(%r{\:+}, '/')
    # Kill weird chars
    path_part = path_part.gsub(%r{[^a-zA-Z0-9\.\-_/]+}, '_')
    # Compact (killing foo/../bar, etc)
    path_part = path_part.gsub(%r{/[^a-zA-Z0-9]+/}, '/').gsub(%r{/\.\.+/}, '.')
    # Kill leading & trailing non-alnum
    path_part = path_part.gsub(%r{^[^a-zA-Z0-9]+}, '').gsub(%r{[^a-zA-Z0-9]+$}, '')
  end

  #
  # name for this URL regarded as a file (instance)
  #
  def to_file_path
    dirname, basename, ext = path_split_str(scrubbed_path)
    basename = join_non_blank '-', basename, uuid
    basename = join_non_blank '.', basename, ext
    join_non_blank '/', root_path, dirname, basename
  end
