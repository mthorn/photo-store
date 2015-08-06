class UploadedFilesController < ApplicationController

  def show
    upload = current_user.library.uploads.find(params[:id])
    if (version = params[:version]).present?
      url = upload.file_url(version)
    else
      url = upload.file_url
    end
    if url
      redirect_to url
    else
      head :not_found
    end
  end

end
