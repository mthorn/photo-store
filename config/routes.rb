Rails.application.routes.draw do

  devise_for :users

  scope 'api' do
    resources :libraries, only: [ :update, :show ] do
      member do
        put :selected, action: :update_selection
        delete :selected, action: :destroy_selection
        put :deleted, action: :restore_deleted
        delete :deleted, action: :remove_deleted
      end
      resources :uploads, only: %i( index create update destroy ) do
        collection do
          post :check
        end
      end
      resources :roles, only: %i( index create update destroy )
      resources :members, only: %i( index create update destroy )
    end
    post 'buffers/:id' => 'buffers#save'
    resource :user, only: :update

    namespace :admin do
      resources :libraries, only: [ :index, :create, :show ]
    end

    post 'jserror' => 'jserrors#log'
  end

  get 'uploaded_files/:id(/:version)' => 'uploaded_files#show', version: /\w+/

  with_options(to: 'main#index') do |app|
    app.root
    scope ':library_id' do
      app.get :gallery
      app.get :slides
    end
    app.get 'admin/*path'
  end

end
