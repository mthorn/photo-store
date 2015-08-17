Rails.application.routes.draw do

  devise_for :users
  devise_for :admins

  scope 'api' do
    resources :libraries, only: [ :update ] do
      member do
        delete :selected, action: :destroy_selection
      end
      resources :uploads, only: %i( index create update destroy ) do
        collection do
          post :check
        end
      end
    end
    post 'buffers/:id' => 'buffers#save'
    resource :user, only: :update
  end

  get 'uploaded_files/:id(/:version)' => 'uploaded_files#show', version: /\w+/

  with_options(to: 'main#index') do |app|
    app.root
    app.get :profile
    scope ':library_id' do
      app.get :gallery
      app.get :slides
    end
  end

end
