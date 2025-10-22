Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }
  get 'render/index'
  
  get "up" => "rails/health#show", as: :rails_health_check

  # Rutas de reservas
  resources :reservas, only: [:index, :show, :edit, :update, :new, :create] do
    member do
      get :cancelar
      get :confirmar
      get :completar
    end
  end

  resources :horarios, only: [:index, :new, :create, :edit, :update, :destroy]

  authenticated :user do
    root "home#index"
  end

  unauthenticated :user do
    root "home#unregistered", as: :user_unregistered
  end  

  resources :reservas do
    resources :mensajes, only: [:index, :create]
  end
end