class LibrariesController < ApplicationController

  before_filter :load_library

  def update
    Library.transaction do
      if (library_params.blank? || @library.update_attributes(library_params)) &&
          (library_membership_params.blank? || @library_membership.update_attributes(library_membership_params))
        render :show
      else
        render json: @library.errors.merge(@library_membership.errors), status: :unprocessable_entity
      end
    end
  end

  def destroy_selection
    if (ids = @library_membership.selection).present?
      @library.uploads.where(id: ids).update_all(deleted_at: Time.current)
      @library_membership.update_attributes!(selection: [])
    end
    head :ok
  end

  private

  def load_library
    @library_membership = current_user.library_memberships.find_by!(library_id: params[:id])
    @library = @library_membership.library
  end

  def library_params
    @library_params ||= params.permit(:name)
  end

  def library_membership_params
    @library_membership_params ||= params.permit(selection: []).tap do |h|
      h[:selection] ||= [] if params.key?(:selection)
    end
  end

end
