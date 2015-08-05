class UploadedFilesController < ApplicationController

  def show
    upload = current_user.library.uploads.find(params[:id])
    if (version = params[:version]).present?
      redirect_to upload.file_url(version)
    else
      redirect_to upload.file_url
    end
  end

end
