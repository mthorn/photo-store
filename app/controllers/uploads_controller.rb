class UploadsController < ApplicationController

  UNIQUE_PARAMS = %i( name size mime )
  SORTABLE_FIELDS = %w( name created_at )

  def index
    @uploads = @library.uploads.where(state: %w( process ready ))
    @count = @uploads.count

    if (offset = params[:offset]).present?
      @uploads = @uploads.offset(offset.to_i)
    end
    if (limit = params[:limit]).present?
      @uploads = @uploads.limit(limit.to_i)
    end
    if (order = params[:order]).present? # format: "field1-asc,field2-desc,..."
      @uploads = @uploads.order(
        order.
          split(',').
          select { |p| p =~ /\A(#{SORTABLE_FIELDS.join('|')})-(asc|desc)\z/o }.
          map { |p| p.split('-', 2) }.
          each.with_object({}) { |(field, sort), h| h[field.to_sym] = sort.to_sym }
      )
    else
      @uploads = @uploads.order(imported_at: :desc, id: :asc)
    end
  end

  def create
    @library.uploads.
      where(state: [ 'upload', 'fail' ]).
      find_by(upload_params.slice(:name, :size, :mime)).
      try(:destroy)

    @upload = @library.uploads.new(upload_params) do |u|
      u.uploader = current_user
    end

    if @upload.save
      render 'show'
    else
      render json: @upload.errors, status: :unprocessable_entity
    end
  end

  def update
    @upload = @library.uploads.find(params[:id])

    if @upload.update_attributes(upload_params)
      render 'show'
    else
      render json: @upload.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @library.uploads.find(params[:id]).destroy
    head :ok
  end

  def check
    check_keys = [ :id ] + UNIQUE_PARAMS
    checks = params[:is_new].presence || []
    result = Upload.connection.execute <<-SQL
      SELECT checks.column1 AS id
      FROM (
        VALUES #{
          checks.map { |c|
            '(' +
            check_keys.map { |k|
              Upload.sanitize(c[k])
            }.join(',') +
            ')'
          }.join(',')
        }
      ) checks
      WHERE (checks.column2, checks.column3, checks.column4) NOT IN (
        SELECT name, size, mime
        FROM uploads
        WHERE library_id = #{@library.id}
      )
    SQL
    render json: (result.map { |r| r['id'].to_i })
  end

  private

  def upload_params
    @upload_params ||= params.permit(
      :file, :modified_at, :name, :size, :mime, :description, :file_uploaded,
      :imported_at)
  end

end
