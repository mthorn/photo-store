class BuffersController < ApplicationController

  before_filter :authenticate_user!

  def save
    buffer = current_user.upload_buffers.find(params[:id])
    if buffer.update_attributes(data: params[:file])
      head :ok
    else
      render json: buffer.errors, status: :unprocessable_entity
    end
  end

end
