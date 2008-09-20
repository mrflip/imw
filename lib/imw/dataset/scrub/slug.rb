require 'rubygems'
require 'addressable/uri'
require 'uuidtools'
require 'scrub'
require 'scrub_simple_url'

module IMW

  #
  #
  # +handle+ -- reasonable effort at a uniq-ish, but human-comprehensible string
  # Handle should only contain the characters A-Za-z0-9_-./
  #
  #
  class Slug
    # A humane representation of the handle ('that-one-time-at_foo')
    attr_reader :handle
    # The purportedly unique string ('')
    attr_accessor :uniqish

    def initialize handle
      self.handle = handle
      self.uniqish  = handle
    end

    #
    # Unless overridden, use the uniqish to
    # make a name-based UUID within the infochimps.org
    # namespace
    #
    def uuid
      UUID.sha1_create(UUID_URL_NAMESPACE, full_handle)
    end

    # Handle with only \w characters -- safe for everything there be
    def url_sane
      return '' if !handle
      handle.gsub(/[^\w\/\:]+/, '-').gsub(/_/, '__').gsub(%r{[/:]+}, '_')
    end

    def handle= t
      @handle = self.class.sanitize_handle(t)
    end

    # Strip all but handle-safe characters
    def self.sanitize_handle t, turd='-'
      t = t.gsub(%r{[^\w\-\./]+}, turd)
    end
  end

  #
  # Uses a URL (that's locator, not URI) as a
  # presumed-uniq identifier.
  #
  # +uniqish+ returns the full normalized URL
  #
  # +handle+ is formed from the dot-reversed host, the scheme (if not http) and a
  # sanitized version of the path. (The query string, fragment, etc are stripped
  # from the handle)
  #
  #
  class URLSlug < Slug
    attr_accessor :url
    def initialize url_str
      self.url     = Addressable::URI.heuristic_parse(url_str).normalize
      raise "Bad URL #{url}" unless url.host
      self.uniqish = url.to_s
      self.handle   = munge_url
    end

    def uuid
      UUID.sha1_create(UUID_URL_NAMESPACE, full_handle)
    end
  end
end



module Sluggable
  protected
  def create_slug
    "Slugging #{self.attributes}"
    if (self.class.slug_on == :url) || (self.name.blank?)
      slug = IMW::URLSlug.new(self.url)
      self.name = slug.handle
    else
      slug = IMW::Slug.new(self.name)
    end
    self.handle ||= slug.handle
  end
  public

  def self.included base
    base.before :save, :create_slug
    base.class_eval do
      def self.slug_on s=nil
        @slug_on ||= s
      end
    end
  end
end
