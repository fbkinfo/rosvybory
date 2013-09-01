Rosvibory::Application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  resources :user_apps, only: [:new, :create] do
  end

  resource :verifications do
    post :confirm
  end

  resources :users, only: [:new, :create, :edit, :update] do
    collection do
      get :group_new
      post :group_create
    end
    member do
      get :dislocate
    end
  end

  root 'user_apps#new'
  get 'confirm_email' => 'user_apps#confirm_email'
  post 'send_group_email' => 'user_apps#send_group_email'
  get 'new_group_email' => 'user_apps#new_group_email'
  post 'send_group_sms' => 'user_apps#send_group_sms'
  get 'new_group_sms' => 'user_apps#new_group_sms'

  namespace :call_center do
    resources :reports
    resources :dislocations
  end
end
