Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/signup', to: 'authentication#signup'
      post 'auth/login', to: 'authentication#login'
      post 'auth/google', to: 'google_auth#authenticate'
      
      # User routes
      get 'users/me', to: 'users#me'
      put 'users/me', to: 'users#update'
      
      # Items routes
      resources :items, only: [:index, :show, :create, :update, :destroy]
      
      # Trades routes
      resources :trades, only: [:index, :show, :create, :update]
    end
  end
end
