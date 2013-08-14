Rosvibory::Application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  resources :user_apps, only: [:new, :create]
  resource :verifications do
    post :confirm
  end

  root 'user_apps#new'
end
