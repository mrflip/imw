
#
# Track a request
#
# class MyScrapeRequest
#   include IMW::ScrapeRequest
#   property :domain_specific_id

# end
#
#
module BaseScrapeRequest
  def scraped?
    !!scraped_at
  end

  module ClassMethods
  end

  def self.included base
    base.class_eval do
      include DataMapper::Resource
      extend ClassMethods
      property :id,             Integer, :serial => true
      property :priority,       Integer
      property :context,        String,  :length => 128
      property :uri,            String,  :length => 1024
      property :requested_at,   DateTime
      property :scraped_at,     DateTime
      property :result_code,    Integer
    end
  end
end
