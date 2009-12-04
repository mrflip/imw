require 'aws/s3'
module IMW
  module Packagers
    class S3Mover

      attr_reader   :last_response
      attr_accessor :bucket_name

      def initialize options={}
        @bucket_name = options.delete(:bucket_name)
        AWS::S3::Base.establish_connection!(options)
      end

      def success?
        errors.empty?
      end

      def success?
        last_response && last_response.class == Net::HTTPOK
      end

      def upload! local_path, remote_path
        @last_response = AWS::S3::S3Object.store(remote_path, open(local_path), bucket_name)
      end
      
    end
  end
end
