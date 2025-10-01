Rails.application.routes.draw do
  devise_for :users , :controllers => {registrations: 'registrations'}
  get 'render/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  
  # Rutas de reservas - SOLO GESTIÓN
  resources :reservas, only: [:index, :show, :edit, :update] do
    member do
      patch :cancelar
    end
  end

  authenticated :user do
    root "home#index"
  end

  unauthenticated :user do
    root "home#unregistered", as: :user_unregistered
  end  


end