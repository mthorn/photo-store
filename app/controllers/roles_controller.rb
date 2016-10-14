class RolesController < ApplicationController

  before_action :authorize_owner!
  before_action :load_role

  def index
    @roles = @library.roles
  end

  def create
    @role = @library.roles.new(role_params)

    if @role.save
      render :show
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  def update
    if @role.update_attributes(role_params)
      render :show
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @role.destroy
    head :ok
  end

  private

  def role_params
    params.permit(:name, :can_upload, restrict_tags: [])
  end

  def load_role
    if id = request.path_parameters[:id]
      @role = @library.roles.find(id)
    end
  end

end
