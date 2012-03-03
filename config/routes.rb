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
  resources :users do
    resources :authentications, only: [:destroy]
  end
  resources :identities
  
  
end
