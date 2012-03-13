Wat::Application.routes.draw do

  get "facilities_controller/index"

  get "facilities_controller/new"

  get "facilities_controller/delete"

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
  end

  # Identity
  # --------
  # The resource for omniauth-identity
  resources :identities

  # Page
  # ----
  # A semi-static page with a title (as key) and a body
  resources :pages

  
end
