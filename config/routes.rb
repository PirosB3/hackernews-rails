Rails.application.routes.draw do
  root "posts#index"

  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :users, only: [:show], param: :username

  resources :posts do
    resources :comments, only: [:create]
  end

  get "newest", to: "posts#newest"
  get "ask", to: "posts#ask"
  get "show_hn", to: "posts#show_hn"

  resources :votes, only: [:create, :destroy]

  get "up/health", to: "rails/health#show", as: :rails_health_check
end
