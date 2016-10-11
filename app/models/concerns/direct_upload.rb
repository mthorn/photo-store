module DirectUpload
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
  end

  # including class needs the following methods:
  #   * %{field}_size
  #   * %{field}_block_size
  #   * process_%{field}_data(iterable)

  def direct_upload_keys field
    size = self.public_send(:"#{field}_size")
    block_size = self.public_send(:"#{field}_block_size")
    block_size = size if block_size <= 0
    (size.to_f / block_size).ceil.times.map do |i|
      "uploads/#{self.class.to_s.underscore.dasherize}-#{self.id}-#{field}-#{i}"
    end
  end

  def create_direct_upload field
    size = self.public_send(:"#{field}_size")
    block_size = self.public_send(:"#{field}_block_size")

    posts = self.direct_upload_keys(field).map.with_index do |key, i|
      offset = i * block_size
      length = [ size, offset + block_size ].min - offset
      if CARRIERWAVE_STORAGE == :fog
        post_data = {
          key: "#{key}",
          AWSAccessKeyId: AWS_ACCESS_KEY_ID,
          acl: 'private'
        }

        post_data[:policy] = policy = [
          {
            expiration: Time.use_zone(nil) { 24.hours.from_now.iso8601 },
            conditions: [
              { bucket: S3_BUCKET_NAME },
              { key: key },
              { acl: 'private' },
              [ 'content-length-range', length, length ]
            ]
          }.to_json
        ].pack('m').gsub("\n", "")

        post_data[:signature] = [
          OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), AWS_SECRET_ACCESS_KEY, policy)
        ].pack('m').gsub("\n", "")

        [ "https://#{S3_BUCKET_NAME}.#{S3_HOST}/", post_data, offset, length ]
      else
        buffer = self.uploader.upload_buffers.create!(key: key, size: length)
        [ "/api/buffers/#{buffer.id}", {}, offset, length ]
      end
    end

    instance_variable_set "@#{field}_posts", posts
    nil
  end

  def fetch_and_process(field)
    self.send(:"process_#{field}_data", Iterable.new(self, field))
  end

  def destroy_buffers(field)
    self.direct_upload_keys(field).each do |key|
      if CARRIERWAVE_STORAGE == :fog
        begin
          S3.delete_object(S3_BUCKET_NAME, key)
        rescue Excon::Errors::NotFound
        end
      else
        UploadBuffer.find_by(key: key).try(:destroy)
      end
    end
  end

  module ClassMethods
    def direct_upload *fields
      fields.each do |field|
        attr_reader :"#{field}_posts"
        attr_accessor :"#{field}_uploaded"

        after_create :create_direct_upload_for_file, unless: :"#{field}?"
        after_commit :"fetch_and_process_#{field}_in_background", if: :"#{field}_uploaded"
        after_commit :"destroy_#{field}_buffers", on: :destroy

        include(mod = Module.new)
        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def create_direct_upload_for_#{field}
            self.create_direct_upload :#{field}
          end

          def fetch_and_process_#{field}_in_background
            self.#{field}_uploaded = false
            ProcessUploadJob.perform_later(self, "#{field}")
          end

          def destroy_#{field}_buffers
            self.destroy_buffers :#{field}
          end
        RUBY
      end
    end
  end

  class Iterable
    def initialize upload, field
      @upload = upload
      @field = field
    end

    def each
      @upload.direct_upload_keys(@field).each.with_index do |key, i|
        if CARRIERWAVE_STORAGE == :fog
          begin
            yield S3.get_object(S3_BUCKET_NAME, key).body
          rescue Excon::Errors::NotFound
            yield :not_found
            break
          end
        else
          if buffer = UploadBuffer.find_by(key: key)
            yield buffer.data.read
          else
            yield :not_found
            break
          end
        end
      end
      nil
    end
  end

end
