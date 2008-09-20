require 'imw/dataset/uri'
require 'imw/dataset/uuid'
require 'dm-serializer'
require 'imw/utils/extensions/class/attribute_accessors'
require 'imw/dataset/link/linkish'

class Link
  include Linkish

  # --
  # note: no trailing / in URL
  UUID_INFOCHIMPS_LINKS_NAMESPACE  = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/links') unless defined?(UUID_INFOCHIMPS_LINKS_NAMESPACE)

  has n,        :linkings
  has n,        :linkables, :through => :linkings
end

