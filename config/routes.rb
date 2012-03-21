# -*- encoding : utf-8 -*-
Wat::Application.routes.draw do

  # Default
  root :to => "home#index"

  # Authentication Routs
  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/identity/register' => 'users#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
  
  # Resources
  # =========
  #
  #  User
  #  ----
  #  Is just the user's name (_login, username, nickname_, ...) and
  #  a valid email-address which the user can edit at any time.
  resources :users do
    resources :authentications, only: [:destroy]
    resources :facilities
    member do
      get 'confirm_email/:token' => :confirm_email, :as => 'confirm_email'
      get 'resend_confirmation_mail' => :resend_confirmation_mail, :as => 'resend_confirmation_mail'
      get 'auth_providers' => :auth_providers
      get 'personal_information' => :personal_information
    end
  end
  

  # Identity
  # --------
  # The resource for omniauth-identity
  resources :identities

  # Page
  # ----
  # A semi-static page with a title (as key) and a body
  resources :pages


  # Language support
  match '/switch_language/:locale' => 'sessions#switch_language', :as => :switch_language

  
end
