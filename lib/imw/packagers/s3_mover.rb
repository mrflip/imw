require 'aws/s3'
module IMW
  module Packagers
    class S3Mover < AWS::S3::Base

      attr_reader   :last_response
      attr_accessor :bucket_name

      def initialize options={}
        @bucket_name = options.delete(:bucket_name)
        self.class.establish_connection!(options) unless self.class.connected?
      end

      def success?
        errors.empty?
      end

      def bucket
        @bucket ||= AWS::S3::Bucket.new :name => bucket_name
      end

      def success?
        last_response == Net::HTTPOK
      end

      def upload! local_path, remote_path
        @last_response = bucket.store(remote_path, open(local_path))
      end
      
    end
  end
end
