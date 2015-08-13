Rails.application.routes.draw do

  devise_for :users
  devise_for :admins

  scope 'api' do
    resources :uploads, only: %i( index create update destroy ) do
      collection do
        post :check
      end
    end
    post 'buffers/:id' => 'buffers#save'
    resource :user, only: :update
  end

  get 'uploaded_files/:id(/:version)' => 'uploaded_files#show', version: /\w+/

  with_options(to: 'main#index') do |app|
    app.root
    %i( gallery slides profile ).each do |page|
      app.get page
    end
  end

end
