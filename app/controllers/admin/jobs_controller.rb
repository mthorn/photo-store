class Admin::JobsController < ApplicationController

  def create
    name = params[:name]
    if name =~ /\ASet\w+Job\z/ || name == 'CreateMissingTranscodesJob' || name == 'BackupDatabaseJob'
      name.constantize.perform_later
      head :ok
    else
      head :forbidden
    end
  rescue NameError
    head :forbidden
  end

end
