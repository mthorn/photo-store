class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :authenticate_user!, unless: :devise_controller?
  around_filter :set_time_zone, if: :user_signed_in?
  before_filter :load_library

  protected

  def set_time_zone
    old_zone = Time.zone
    Time.zone = current_user.time_zone_auto
    begin
      yield
    ensure
      Time.zone = old_zone
    end
  end

  def load_library
    if (id = request.path_parameters[:library_id]).present?
      @library_membership = current_user.library_memberships.find_by!(library_id: id)
      @library = @library_membership.library
    end
  end

  def authorize_owner!
    if @library_membership.nil? || ! @library_membership.owner?
      head :forbidden
    end
  end

  def authorize_upload!
    if @library_membership.nil? || ! @library_membership.can_upload?
      head :forbidden
    end
  end

end

