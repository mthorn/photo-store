class UploadedFilesController < ApplicationController

  def show
    upload = current_user.uploads.find(params[:id])
    if (version = params[:version]).present?
      url = upload.file_url(version)
    else
      url = upload.file_url
    end

    if CARRIERWAVE_STORAGE == :file && url[0] == '/' && url[1] != '/'
      type =
        case version
        when 'large', 'gallery' then 'image/jpeg'
        when 'transcoded' then 'video/mp4'
        else upload.mime
        end
      send_file url, type: type, disposition: 'inline'
    elsif url
      redirect_to url
    else
      head :not_found
    end
  end

end
