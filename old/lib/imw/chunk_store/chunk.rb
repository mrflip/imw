require 'imw/dataset/datamapper'
require 'imw/dataset/link/linkish'

class LinkAsset
  UUID_INFOCHIMPS_ASSETS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/assets') unless defined?(UUID_INFOCHIMPS_ASSETS_NAMESPACE)
  include Linkish
end


#
# Track, in an arbitrary context, whether an asset has been processed
#
class Processing
  include DataMapper::Resource
  property      :id,             Serial
  property      :asset_id,       Integer,                     :unique_index => :asset_context
  property      :context,        String,    :length => 40,    :unique_index => :asset_context
  property      :asset_type,     String,    :length => 40,    :unique_index => :asset_context
  property      :processed_at,   DateTime
  property      :success,        Boolean,                     :default => false
  property      :result,         Text
end


module Asset
  #
  # Help track assets being processed.
  #
  module Processor

    def processed asset, context, result
      asset_id = asset.respond_to?(:attributes) ? asset.id : asset.hash
      processing = Processing.find_or_create :context => context, :asset_id => asset_id, :asset_type => asset.class.to_s
      processing.result       = result
      processing.success      = !! result
      processing.processed_at = Time.now.utc
      processing.save
    end

    # reset -- clear all processings from the given context
    def unprocess_all context
      Processing.all(:context => context).each(&:destroy) # Clear all out
    end

    def processed_successfully? asset, context
      processing = Processing.first :context => context, :asset_id => asset.id, :asset_type => asset.class.to_s
      processing && processing.success
    end

    def load_pool_from_disk root, path
      assets = []
      cd path_to(root) do
        announce "Loading from #{path.inspect}"
        Dir[path_to(path)].reject{|f| ! File.file?(f)}.each do |ripd_file|
          assets << LinkAsset.find_or_create_from_file_path(ripd_file)
        end
      end
      assets
    end

    def process assets, context, parser
      results = []
      assets.each do |asset|
        unless processed_successfully?(asset, context)
          announce "#{context} - processing #{asset.id} #{asset}"
          begin
            result = parser.parse(asset)
            processed asset, context, result.to_yaml
            results << result
          rescue Exception => e
            result = nil
            processed asset, context, nil
            processed asset, :error, nil
            warn "Couldn't parse #{asset.attributes.to_yaml[0..5000]}: #{e}"
          end
        else
          announce "#{context} - skipping #{asset}"
        end
      end
      results
    end

    module ClassMethods
    end
    def self.included base
      base.extend ClassMethods
    end
  end
end



class LinkAsset
  UUID_INFOCHIMPS_ASSETS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/assets') unless defined?(UUID_INFOCHIMPS_ASSETS_NAMESPACE)
  include Linkish
end

class OldFormatAsset < LinkAsset
  def to_file_path_host_part
    tiered_host_part = super
    m = %r{\A
          (#{Addressable::URI::HOST_TLD})   # tld tier
          /(..?)                            # revhost tier
          /(.+)                             # revhost
    \z}x.match(tiered_host_part)
    raise "Can't extract url from tiered host path part #{tiered_host_part}" if !m
    revhost_only = m.captures(2)
    revhost_only
  end
end
