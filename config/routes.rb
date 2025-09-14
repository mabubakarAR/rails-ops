Rails.application.routes.draw do
  root 'home#index'
  
  devise_for :users
  
  resources :jobs do
    resources :job_applications, only: [:create, :index, :show, :update, :destroy]
  end
  
  resources :companies
  resources :job_seekers
  resources :job_applications, only: [:index, :show, :update, :destroy]
  
  namespace :api do
    namespace :v1 do
      get "search/jobs"
      get "search/companies"
      get "search/job_seekers"
      # Authentication routes
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      post 'auth/logout', to: 'auth#logout'
      get 'auth/profile', to: 'auth#profile'
      put 'auth/profile', to: 'auth#update_profile'

      # Job routes
      resources :jobs do
        member do
          post :activate
          post :pause
          post :close
        end
        resources :job_applications, only: [:index, :create]
      end

      # Job Application routes
      resources :job_applications do
        member do
          patch :update_status
          post :withdraw
        end
      end

      # Company routes
      resources :companies do
        member do
          get :jobs
          get :applications
        end
      end

      # Job Seeker routes
      resources :job_seekers do
        member do
          get :applications
          get :skills
          post :add_skill
          delete :remove_skill
        end
      end

      # Category and Skill routes
      resources :categories, only: [:index, :show] do
        resources :skills, only: [:index, :show]
      end

      # Search routes
      get 'search/jobs', to: 'search#jobs'
      get 'search/companies', to: 'search#companies'
      get 'search/job_seekers', to: 'search#job_seekers'
    end
  end

  # Admin routes (will add later)
  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
