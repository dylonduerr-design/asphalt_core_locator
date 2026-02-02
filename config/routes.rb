Rails.application.routes.draw do
  resources :lanes
  resources :sublots do
    member do
      patch :toggle_core_lock
    end
  end
  resources :lots do
    collection do
      post :quick_create
      get :all, action: :all_lots
    end
    resource :bulk_setup, only: [:new, :create]
    resources :core_generations, only: [:new, :create, :show] do
      get :export_csv, on: :member
      post :create_for_sublot, on: :collection
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "lots#index"
end
