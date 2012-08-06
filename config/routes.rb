# -*- encoding : utf-8 -*-
Wat::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  # Default
  root :to => "home#index"

  # Authentication Routs
  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/identity/register' => 'users#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
  match '/twitter_user/:screen_name/:max_entries' => 'twitter#user_tweets', :as => :twitter_user
  
  # Resources
  # =========
  #
  #  User
  #  ----
  #  Is just the user's name (_login, username, nickname_, ...) and
  #  a valid email-address which the user can edit at any time.
  resources :users do
    resources :authentications, only: [:destroy]
    resource  :profile
    resource  :avatar do
      member do
        put :crop_avatar
      end
    end
    
    resources :facilities
    resources :attachments
    collection do
      get 'forgot_password' => :forgot_password
      post 'send_password_reset_token' => :send_password_reset_token
    end
    member do
      get 'confirm_email/:token' => :confirm_email, :as => 'confirm_email'
      get 'resend_confirmation_mail' => :resend_confirmation_mail, :as => 'resend_confirmation_mail'
      get 'auth_providers' => :auth_providers
      get 'reset_password/:token' => :reset_password, as: 'reset_password'
    end
  end

  resources :attachments

  # Contact
  # -------
  # There is no Contact-model! Contacts are handled through facilities shared
  # between users.
  resources :contacts 
  resources :contact_invitations
  match '/accept_contact_invitation/:token' => 'contact_invitations#update', :as => :accept_contact_invitation


  # Identity
  # --------
  # The resource for omniauth-identity
  resources :identities

  # Page
  # ----
  # A semi-static page with a title (as key) and a body
  resources :pages do
    get 'translate_to/:locale' => :translate_to, :as => 'translate_to'
    get 'read_translation_of/:locale' => :read_translation_of, :as => 'read_translation_of'
    collection do
      get  'sort' => :sort
      post 'update_sort' => :update_sort
    end
    resources :comments
  end

  # Search
  resources :searches, only: [:new,:create]

  # Section
  # -------
  resources :sections do
    collection do
      get  'sort' => :sort
      post 'update_sort' => :update_sort
    end
  end

  # Language support
  match '/switch_language/:locale' => 'sessions#switch_language', :as => :switch_language

  
end
