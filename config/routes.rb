Wat::Application.routes.draw do

  # Authentication Routs
  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/identity/register' => 'users#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
  
  # Resources
  resources :users
  resources :identities 
  
  # Default
  root :to => "home#index"

end
