class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :authenticate_user!, unless: :devise_controller?
  before_filter :load_library

  def load_library
    if (id = params[:library_id]).present?
      @library = current_user.libraries.find(id)
    end
  end

end
