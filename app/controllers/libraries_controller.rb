class LibrariesController < ApplicationController

  before_filter :load_library
  before_filter :authorize_owner!, only: :update
  before_filter :authorize_upload!, only: [ :destroy_selection, :restore_deleted, :remove_deleted ]

  def update
    Library.transaction do
      if (library_params.blank? || @library.update_attributes(library_params)) &&
          (library_membership_params.blank? || @library_membership.update_attributes(library_membership_params))
        render :show
      else
        render json: @library.errors.to_hash.merge(@library_membership.errors.to_hash), status: :unprocessable_entity
      end
    end
  end

  def show
  end

  def update_selection
    @library_membership.update_selected(params.permit(:tags))
    render :show
  end

  def destroy_selection
    if (ids = @library_membership.selection).present?
      @library.uploads.where(id: ids).update_all(deleted_at: Time.current)
      @library_membership.update_attributes!(selection: [])
    end
    render :show
  end

  def restore_deleted
    @library.uploads.deleted.update_all(deleted_at: nil)
    render :show
  end

  def remove_deleted
    @library.uploads.deleted.update_all(state: 'destroy')
    DestroyUploadsJob.perform_later
    render :show
  end

  private

  def load_library
    @library_membership = current_user.library_memberships.find_by!(library_id: params[:id])
    @library = @library_membership.library
  end

  def library_params
    @library_params ||= params.permit(:name, :tag_new, :tag_aspect, :tag_date, :tag_camera, :tag_location)
  end

  def library_membership_params
    @library_membership_params ||= params.permit(selection: []).tap do |h|
      h[:selection] ||= [] if params.key?(:selection)
    end
  end

end
