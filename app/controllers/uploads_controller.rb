class UploadsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @uploads = current_user.library.uploads.where(state: %w( process ready ))
    @count = @uploads.count

    if (offset = params[:offset]).present?
      @uploads = @uploads.offset(offset.to_i)
    end
    if (limit = params[:limit]).present?
      @uploads = @uploads.limit(limit.to_i)
    end

    @uploads = @uploads.order(imported_at: :desc, id: :asc)
  end

  def create
    current_user.library.uploads.
      where(state: [ 'upload', 'fail' ]).
      find_by(upload_params.slice(:name, :size, :mime)).
      try(:destroy)

    @upload = current_user.library.uploads.new(upload_params) do |u|
      u.uploader = current_user
    end

    if @upload.save
      render 'show'
    else
      render json: @upload.errors, status: :unprocessable_entity
    end
  end

  def update
    @upload = current_user.library.uploads.find(params[:id])

    if @upload.update_attributes(upload_params)
      render 'show'
    else
      render json: @upload.errors, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.library.uploads.find(params[:id]).destroy
    head :ok
  end

  private

  def upload_params
    @upload_params ||= params.permit(
      :file, :modified_at, :name, :size, :mime, :description, :file_uploaded,
      :imported_at)
  end

end
