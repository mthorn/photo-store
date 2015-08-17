class UsersController < ApplicationController

  def update
    @user = current_user

    if @user.update_attributes user_params
      sign_in(:user, @user) if @user.previous_changes['encrypted_password'].present?
      render :show
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :manual_deselect)
  end

end
