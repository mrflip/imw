require 'imw/dataset/datamapper'
require 'imw/dataset/link/linkish'
#
# A file to process
#
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
  property      :context,        String,    :length => 40,    :unique_index => :asset_context
  property      :asset_id,       Integer,                     :unique_index => :asset_context
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
      processing = Processing.find_or_create :context => context, :asset_id => asset.id, :asset_type => asset.class.to_s
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
          announce "processing #{asset}"
          begin
            result = parser.parse(asset)
            processed asset, context, result.to_yaml
            results << result
          rescue Exception => e
            result = nil
            processed asset, context, nil
            warn "Couldn't parse #{asset.attributes}: #{e}"
          end
        else
          announce "skipping #{asset}"
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

# #
# # The filestore cache of an asset.
# #
# class FileAsset
#
#   # property      :rippable_type,   String,    :length =>  10,    :nullable => false, :index => :rippable_param,     :index => :rippable_user
#   # property      :rippable_param,  String,    :length => 255,                    :index => :rippable_param
#   # property      :rippable_user,   String,    :length =>  50,                    :index => :rippable_user
#   # property      :ripped_page,     Integer
#   #
#   # # FIXME -- make it before_save; denormalize.
#   # def set_rippable_info_from_url!
#   #   # pull page from query string
#   #   _, page = %r{page=(\d+)}.match(self.query).to_a
#   #   page ||= 1
#   #   # pull type, param from path
#   #   _, type, param = %r{^/([^/]+)(?:/(.*?))?$}.match(self.path).to_a
#   #   case
#   #   when ['tag', 'url'].include?(type)  then type, user, param = [type,       nil,  param]
#   #   when ['search'].include?(type)      then type, user, param = [type,       nil,  self.query]
#   #   when param.blank?                   then type, user, param = ['user',     type, nil]
#   #   else                                     type, user, param = ['user_tag', type, param] end
#   #   # save grokked result
#   #   self.rippable_type, self.rippable_param, self.rippable_user, self.ripped_page = [type, param, user, page]
#   #   self.save
#   #   self
#   # end
#   # def description
#   #   case self.rippable_type
#   #   when 'tag', 'url', 'search' then "page %3d for %-4s %s"        % [self.ripped_page, self.rippable_type+':',  self.rippable_param]
#   #   when 'user'                 then "page %3d for %-4s %s"        % [self.ripped_page, self.rippable_type,      self.rippable_user]
#   #   when 'user_tag'             then "page %3d for user %-20s tag %s" % [self.ripped_page, self.rippable_user+"'s", self.rippable_param]
#   #   else
#   #     self.to_s
#   #   end
#   # end
# end
# end

