module DirectUpload
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
  end

  def direct_upload_key field
    "uploads/#{self.class.to_s.underscore.dasherize}-#{self.id}-#{field}"
  end

  def create_direct_upload field
    key = self.direct_upload_key(field)

    if S3
      url = "https://#{S3_BUCKET_NAME}.#{S3_HOST}/"
      post_data = {
        key: "#{key}",
        AWSAccessKeyId: AWS_ACCESS_KEY_ID,
        acl: 'private'
      }

      post_data[:policy] = policy = [
        {
          expiration: 24.hours.from_now.iso8601,
          conditions: [
            { bucket: S3_BUCKET_NAME },
            { key: key },
            { acl: 'private' },
            [ 'content-length-range', 0, 2 ** 30 ]
          ]
        }.to_json
      ].pack('m').gsub("\n", "")

      post_data[:signature] = [
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), AWS_SECRET_ACCESS_KEY, policy)
      ].pack('m').gsub("\n", "")
    else
      buffer = self.uploader.upload_buffers.create!(key: key)
      url = "/api/buffers/#{buffer.id}"
      post_data = {}
    end

    instance_variable_set "@#{field}_post_url", url
    instance_variable_set "@#{field}_post_data", post_data
    nil
  end

  def move_and_process(field)
    file_data = nil
    key = self.direct_upload_key(field)

    if S3
      begin
        s3_obj = S3.get_object(S3_BUCKET_NAME, key)
        S3.delete_object(S3_BUCKET_NAME, key)
        file_data = s3_obj.body
      rescue Excon::Errors::NotFound
      end
    else
      if buffer = UploadBuffer.find_by(key: key)
        file_data = buffer.data.read
        buffer.destroy
      end
    end

    if file_data
      file_name = self.send(:"#{field}_name")
      file = Tempfile.new(file_name.gsub(/\s+/, '_').split(/(?=\.[^.]+\z)/), encoding: 'BINARY')
      begin
        file.write file_data
        file.rewind
        self.send(:"process_#{field}", file)
      ensure
        file.close
        file.unlink
      end
    else
      self.send(:"process_#{field}", :not_found)
    end
  end

  module ClassMethods
    def direct_upload *fields
      fields.each do |field|
        attr_reader :"#{field}_post_url", :"#{field}_post_data"
        attr_accessor :"#{field}_uploaded"

        after_save :"move_and_process_#{field}", if: :"#{field}_uploaded"

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def create_direct_upload_for_#{field}
            self.create_direct_upload :#{field}
          end

          def move_and_process_#{field}
            self.#{field}_uploaded = false
            self.move_and_process :#{field}
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
