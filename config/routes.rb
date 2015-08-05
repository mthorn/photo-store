Rails.application.routes.draw do

  devise_for :users
  devise_for :admins

  scope 'api' do
    resources :uploads
  end

  get 'uploaded_files/:id(/:version)' => 'uploaded_files#show', version: /\w+/

  root to: 'main#index'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

end
