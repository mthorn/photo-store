class MembersController < ApplicationController

  before_filter :authorize_owner!
  before_filter :load_member

  def index
    @library_memberships = @library.library_memberships.includes(:user)
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.where(email: user_params[:email]).first_or_initialize(user_params) do |m|
        m.password = Devise.friendly_token
        m.default_library = @library
      end
      @library_membership = @library.library_memberships.new(library_membership_params) do |lm|
        lm.user = @user
      end
      invite = @user.new_record?

      if (@user.persisted? || @user.save) && @library_membership.save
        render :show
        @user.send_reset_password_instructions if invite
      else
        render json: @user.errors.to_hash.merge(@library_membership.errors.to_hash), status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def update
    if @library_membership.update_attributes(library_membership_params)
      render :show
    else
      render json: @library_membership.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @library_membership.destroy
    head :ok
  end

  private

  def user_params
    params.permit(:name, :email)
  end

  def library_membership_params
    params.permit(:role_id)
  end

  def load_member
    if id = request.path_parameters[:id]
      @library_membership = @library.library_memberships.find(id)
      @user = @library_membership.user
    end
  end

end
