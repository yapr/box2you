Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root "home#index"

  # Books routes
  resources :books, only: [ :index, :show ] do
    collection do
      get :search
    end
  end

  # Amazon Products routes
  resources :amazon_products, only: [ :index, :show ], path: 'amazon' do
    collection do
      get :search
    end
  end

  # Home routes
  get "home/index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
