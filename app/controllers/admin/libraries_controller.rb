class Admin::LibrariesController < ApplicationController

  def index
    @libraries = Library.all
  end

  def create
    ApplicationRecord.transaction do
      @library = Library.new(library_params)
      @user = User.where(email: user_params[:email]).first_or_initialize(user_params)
      invite = @user.new_record?

      if @library.save && @user.update_attributes(default_library_id: @user.default_library_id || @library.id)
        render :show
        @user.library_memberships.create!(
          library: @library,
          role: @library.owner_role
        )
        @user.send_reset_password_instructions if invite
      else
        render json: @library.errors.to_hash.merge(user: @user.errors.to_hash), status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def library_params
    params.permit(:name)
  end

  def user_params
    params.require(:user).permit(:name, :email).merge(password: Devise.friendly_token)
  end

end
