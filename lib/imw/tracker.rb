# require "dm-more/dm-timestamps"


#
# Help track assets being processed.
#
module IMW
  # class TaskRequest
  #
  #   property   :uniq_name,          String,       :length => 1024,        :unique_index => true
  #   property   :twitter_user_id,    Integer,                              :index => [:user_resource_page]
  #   property   :page,               Integer,                              :index => [:user_resource_page]
  #   # connect to twitter model
  #   # def self.request(uri, priority)
  #   #   req = self.find_or_create({ :uri =>  uri })
  #   #   req.priority = [req.priority, priority].min
  #   #   req if req.save
  #   # end
  #
  #   module ClassMethods
  #   end
  #   def self.included base
  #     base.extend ClassMethods
  #     include DataMapper::Resource
  #     property   :id,                 Integer,      :serial => true
  #     property   :priority,           Integer,      :index  => true,        :index => [:priority]
  #     property   :result_code,        Integer
  #     property   :attempted,          Boolean
  #     property   :context,            String,       :length => 25,          :index => [:user_resource_page]
  #     timestamps :at
  #   end
  #
  # end

  class Tracker
    attr_accessor       :request_klass
    attr_accessor       :context
    attr_accessor       :chunk_size
    attr_accessor       :query_options
    attr_accessor       :options
    def initialize request_klass, context, chunk_size=100, options={}
      # raise "Incorrect number of shards: must have #{shard} strictly less than #{shards} (shard 0 is the first)" unless shard < shards
      self.request_klass = request_klass
      self.context       = context
      self.chunk_size    = chunk_size
      self.query_options = options[:query_options]
      self.options       = options
    end
    def shard()         @shard ||= options[:shard] || 0  end
    def dry_run()       options[:dry_run]       end
    def chunk_offset()  options[:offset] || 0   end

    #
    def each &block
      (0..max_chunk).each do |chunk_idx|
        process_chunk chunk_idx, &block
      end
    end

    #
    def process_chunk chunk_idx, &block
      track_count "#{context}_chunk".to_sym, 1
      chunk = request_klass.all( chunk_query_params(chunk_idx) )
      process_chunk_requests chunk, &block
    end

    def new_chunk_hook chunk_idx
    end

    #
    #
    #
    def process_chunk_requests chunk, &block
      chunk.each do |request|
        request.result_code  = yield(request) || false
        next if dry_run
        request.scraped_time = Time.now.utc
        request.save
      end
    end

    #
    def max_chunk
      case
      when @max_chunk          then return @max_chunk
      when options[:max_chunk]  then return @max_chunk = options[:max_chunk]
      else
        total = request_klass.count :scraped_time => nil, :user_resource => context
        @max_chunk = (total / chunk_size) - chunk_offset
      end
    end

    #
    def chunk_query_params chunk_idx
      query_options.merge({
          :scraped_time    => nil,
          :user_resource   => context,
          :limit           => chunk_size,
          :offset          => chunk_offset + (chunk_idx*chunk_size),
      })
    end

    def reset_all
      puts context
      request_klass.all(:scraped_time => nil, :user_resource => context).each do |req|
        req.update_attributes :result_code => nil, :scraped_time => nil
        req.save
      end
    end
  end # Tracker

  class PriorityQueueTracker < Tracker
    def chunk_offset
      chunk_size * 4 * shard
    end
    #
    # this won't actually cover the whole set correctly.
    #
    def chunk_query_params chunk_idx
      super(context, query_options).merge :order => [:priority.asc]
    end
  end

  class SerialTracker < Tracker
    def chunk_query_params chunk_idx
      super(context, query_options).merge :order => [:id.asc],
        :id.gte => chunk_size*(chunk_idx),
        :id.lt  => chunk_size*(chunk_idx + 1)
    end
  end

  class SerialPriorityTracker < Tracker
    def chunk_query_params chunk_idx
      super(chunk_idx).merge :order => [:priority.asc],
        :offset       => 0, :limit => chunk_size * 5,
        :priority.gte => chunk_offset + chunk_size*(chunk_idx),
        :priority.lt  => chunk_offset + chunk_size*(chunk_idx + 1)
    end
  end

end



# #
# # Push a request onto the queue for later execution
# #
# def queue
# end
#
# def normalize
#   # set priority
# end
#   def processed asset, context, result
#     asset_id = asset.respond_to?(:attributes) ? asset.id : asset.hash
#     processing = TaskRequest.find_or_create :context => context, :asset_id => asset_id, :asset_type => asset.class.to_s
#     processing.result       = result
#     processing.success      = !! result
#     processing.processed_at = Time.now.utc
#     processing.save
#   end
#
#   # # reset -- clear all processings from the given context
#   # def unprocess_all context
#   #   TaskRequest.all(:context => context).each(&:destroy) # Clear all out
#   # end
#
#   def processed_successfully? asset, context
#     processing = TaskRequest.first :context => context, :asset_id => asset.id, :asset_type => asset.class.to_s
#     processing && processing.success
#   end
#
#   def process assets, context, parser
#     results = []
#     assets.each do |asset|
#       unless processed_successfully?(asset, context)
#         announce "#{context} - processing #{asset.id} #{asset}"
#         begin
#           result = parser.parse(asset)
#           processed asset, context, result.to_yaml
#           results << result
#         rescue Exception => e
#           result = nil
#           processed asset, context, nil
#           processed asset, :error, nil
#           warn "Couldn't parse #{asset.attributes.to_yaml[0..5000]}: #{e}"
#         end
#       else
#         announce "#{context} - skipping #{asset}"
#       end
#     end
#     results
#   end
# end
#
#
# class TaskQueuer
#
# end
#
#
# class QueueFiles
#   def load_pool_from_disk root, path
#     assets = []
#     cd path_to(root) do
#       announce "Loading from #{path.inspect}"
#       Dir[path_to(path)].reject{|f| ! File.file?(f)}.each do |ripd_file|
#         assets << LinkAsset.find_or_create_from_file_path(ripd_file)
#       end
#     end
#     assets
#   end
# end
