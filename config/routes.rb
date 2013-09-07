Rosvibory::Application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  #resources :user_apps, only: [:new, :create] do
  #end

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
      get :letter
      get :direct_login
    end
  end

  root 'user_apps#closed'

  get 'confirm_email' => 'user_apps#confirm_email'
  post 'send_group_email' => 'user_apps#send_group_email'
  get 'new_group_email' => 'user_apps#new_group_email'
  post 'send_group_sms' => 'user_apps#send_group_sms'
  get 'new_group_sms' => 'user_apps#new_group_sms'

  namespace :call_center do
    resources :reports do
      member do
        get :confirm
      end
    end
    resources :violations, only: :index

    resources :uics do
      collection do
        get :by_user
      end
    end

    resources :dislocations do
      collection do
        get :by_phone
      end
    end
  end
end
