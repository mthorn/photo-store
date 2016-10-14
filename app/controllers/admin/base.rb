class Admin::Base < ApplicationController

  before_action :authorize_admin!

  protected

  def authorize_admin!
    if ! current_user.admin?
      head :forbidden
    end
  end

end
