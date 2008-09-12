require 'addressable/uri'
require 'imw/dataset/uuid'
module IMW
  # note: no trailing /
  UUID_INFOCHIMPS_ASSETS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/assets') unless defined?(UUID_INFOCHIMPS_ASSETS_NAMESPACE)
  module URI
    module FileStore
      #
      # name for this URL regarded as a directory (container)
      #
      def dir_path
        join_non_blank '/', root_path, scrubbed_path
      end

      #
      # name for this URL regarded as a file (instance)
      #
      def file_path
        dirname, basename, ext = path_split_str(scrubbed_path)
        basename = join_non_blank '-', basename, uuid
        basename = join_non_blank '.', basename, ext
        join_non_blank '/', root_path, dirname, basename
      end

      def path_split
        path_split_str path
      end

      # lowercase; only a-z, num, . -
      def scrubbed_revhost
        return unless revhost
        revhost.downcase.gsub(/[^a-z0-9\.\-]+/i, '')  # note: no _
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

      protected
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
        if basename =~ %r{.+\.[^\.]+}
          basename, ext = /\A(.+?)\.(tar\.gz|tar\.bz2|[^\.]+)\z/i.match(basename).captures
        else
          basename, ext = [basename, '']
        end
        [dirname, basename, ext]
      end

      # remove all blank components, join the rest with separator
      def join_non_blank separator, *strs
        strs.reject(&:blank?).join(separator)
      end
      # if http:  revhost
      # else:     revhost_scheme
      def root_path
        if revhost && (scheme == 'http')
          revhost
        else
          "#{revhost}_#{scheme}"
        end
      end
    end
  end
end
