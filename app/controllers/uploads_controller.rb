class UploadsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @uploads = current_user.library.uploads
  end

  def create
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
    params.permit(:file, :modified_at, :name, :size, :mime, :description,
                  :file_uploaded)
  end

end
