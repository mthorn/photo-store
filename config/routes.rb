Rails.application.routes.draw do

  devise_for :users
  devise_for :admins

  scope 'api' do
    resources :uploads do
      collection do
        post :check
      end
    end
    post 'buffers/:id' => 'buffers#save'
  end

  get 'uploaded_files/:id(/:version)' => 'uploaded_files#show', version: /\w+/

  with_options(to: 'main#index') do |app|
    app.root
    %i( gallery slides ).each do |page|
      app.get page
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

end
