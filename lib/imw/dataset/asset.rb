require 'imw/dataset'
require 'imw/dataset/link'

#
# A file to process
#
#module Asset
#  class Base < Link
class Link
    include DataMapper::Resource
    property      :file_path,       String,    :length => 1024
    property      :file_date,       DateTime
    property      :file_size,       Integer
    property      :fetched,         Boolean

    #
    # The standard file path for this url's ripped cache
    #
    def ripd_file
      return @ripd_file if @ripd_file
      @ripd_file = File.join(host, path).gsub(%r{/+$},'') # kill terminal '/'
      @ripd_file = File.join(@ripd_file, 'index.html') if File.directory?(@ripd_file)
      @ripd_file
    end

    #
    # Refresh cached properties from our copy of the asset.
    #
    def update_from_file!
      self.file_size = File.size( file_path)
      self.file_time = File.mtime(file_path)
      ripd.save
    end

    #
    # Fetch from the web
    #
    def wget options={}
      options = {
        :root       => path_to(:ripd_root),
        :wait       => 2,
        :noretry    => true,
        :noisy      => true,
        :clobber    => false,
      }.merge(options)
      cd path_to(options[:root]) do
        if (not options[:clobber]) && File.file?(ripd_file) then
          puts "Skipping #{ripd_file}" if options[:noisy]; return
        end
        # Do the fetch
        cmd = %Q{wget -nv "#{full_url}" -O"#{ripd_file}"}
        puts cmd if options[:noisy]
        print `#{cmd}`
        success = File.exists?(ripd_file)
        if !success && options[:noretry]
          puts "wget failed; leaving a turd in #{ripd_file}"
          FileUtils.mkdir_p File.dirname(ripd_file)
          FileUtils.touch ripd_file
        end
        # Sleep for a bit -- no hammer.
        sleep options[:wait]
        return success
      end
    end
  end
  
  
  #
  # Track, in an arbitrary context, whether an asset has been processed
  #
  class Processing
    include DataMapper::Resource      
    property      :context,        String,    :length => 40,    :key => true
    property      :asset_id,       Integer,   :length => 40,    :key => true
    property      :processed_at,   DateTime
    property      :success,        Boolean,                     :default => false
  end

  
  #
  # Help track assets being processed.
  #
  module Processor
    def processed asset, success
      processing = self.processings.find_or_create :context => self.processing_context, :asset_id => asset
      processing.success      = success
      processing.processed_at = Time.now.utc
      processings << processing
      processing.save
    end
    
    module ClassMethods
      def processes context
        cattr_accessor :processing_context
        self.processing_context = context
        base.has n, :processings
      end
    end
    
    def included base
      base.extend ClassMethods
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
