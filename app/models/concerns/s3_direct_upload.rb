module S3DirectUpload
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
  end

  def s3_key field
    "uploads/#{self.class.to_s.underscore.dasherize}-#{self.id}-#{field}"
  end

  def create_direct_upload_meta_data field
    if AWS_ACCESS_KEY_ID && AWS_SECRET_ACCESS_KEY && S3_BUCKET_NAME
      key = self.s3_key(field)
      instance_variable_set "@#{field}_s3_target", "https://#{S3_BUCKET_NAME}.#{S3_HOST}/"
      fields = {
        key: "#{key}",
        AWSAccessKeyId: AWS_ACCESS_KEY_ID,
        acl: 'private'
      }

      fields[:policy] = policy = [
        {
          expiration: 24.hours.from_now.iso8601,
          conditions: [
            { bucket: S3_BUCKET_NAME },
            { key: key },
            { acl: 'private' },
            [ 'content-length-range', 0, 104857600 ]
          ]
        }.to_json
      ].pack('m').gsub("\n", "")

      fields[:signature] = [
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), AWS_SECRET_ACCESS_KEY, policy)
      ].pack('m').gsub("\n", "")

      instance_variable_set "@#{field}_s3_post_data", fields
    end
  end

  def download_and_process(field)
    return unless S3

    key = self.s3_key(field)
    begin
      s3_obj = S3.get_object(S3_BUCKET_NAME, key)
    rescue Excon::Errors::NotFound
      self.send(:"process_#{field}", :not_found)
    else
      S3.delete_object(S3_BUCKET_NAME, key)

      file_name = self.send(:"#{field}_name")
      file = Tempfile.new(file_name.gsub(/\s+/, '_').split(/(?=\.[^.]+\z)/), encoding: 'BINARY')
      begin
        file.write s3_obj.body
        file.rewind
        self.send(:"process_#{field}", file)
      ensure
        file.close
        file.unlink
      end
    end
  end

  module ClassMethods
    def s3_upload *fields
      fields.each do |field|
        attr_reader :"#{field}_s3_target", :"#{field}_s3_post_data"
        attr_accessor :"#{field}_uploaded"

        after_save :"download_and_process_#{field}", if: :"#{field}_uploaded"

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def create_direct_upload_meta_data_for_#{field}
            self.create_direct_upload_meta_data :#{field}
          end

          def download_and_process_#{field}
            self.#{field}_uploaded = false
            self.download_and_process :#{field}
          end

          def process_#{field} file
            if file != :not_found
              self.update_attributes! :#{field} => file
            end
          end
        RUBY
      end
    end
  end

end
