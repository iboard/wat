# -*- encoding : utf-8 -*-
Wat::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :timelines do
        member do
          get  :events
          post :create_event
        end
      end
    end
  end

  # Default
  root :to => "home#index"

  # Translations
  resources :translations do
    collection do
      post '/edit_page_translations' => :index, :as => :edit_page
    end
  end


  # Authentication Routes
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
    resources :attachments do
      collection do
        get 'upload_finished' => :upload_finished
      end
    end
    collection do
      get 'forgot_password' => :forgot_password
      post 'send_password_reset_token' => :send_password_reset_token
      get 'autocomplete_search' => :autocomplete_search
    end
    member do
      get 'confirm_email/:token' => :confirm_email, :as => 'confirm_email'
      get 'resend_confirmation_mail' => :resend_confirmation_mail, :as => 'resend_confirmation_mail'
      get 'auth_providers' => :auth_providers
      get 'reset_password/:token' => :reset_password, as: 'reset_password'
      get 'timeline_subscription/:timeline_id/:timeline_action' => :subscribe_timeline, as: 'subscribe_timeline'
    end
    resource :timeline
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
      get 'autocomplete_search' => :autocomplete_search
    end
    member do
      get 'restore_version/:version' => :restore_version, :as => 'restore_version'
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

  # Timeline and Subscriptions
  # --------------------------
  resources :timelines do
    resources :timeline_events
    collection do
      get 'user/:user_id' => :user, as: :user
      post 'user/:user_id' => :update, as: :update_user_timeline
      put  'user/:user_id' => :update
      get 'toggle'   => :toggle, as: :toggle
      get 'update_timeline'   => :update_timeline, as: :update_timeline
    end
  end

  
end
