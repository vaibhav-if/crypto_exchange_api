Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      # Users
      post "users/signup", to: "users#signup"
      post "users/login", to: "users#login"

      # wallets
      post "/wallets/deposit", to: "wallets#deposit"
      post "/wallets/withdrawal", to: "wallets#withdrawal"
      get "/wallets/balances", to: "wallets#balances"

      # orders
      post "/orders/create", to: "orders#create"
      put "/orders/cancel", to: "orders#cancel"

      # dashboards
      get "/dashboards/index", to: "dashboards#index"
    end
  end
end
