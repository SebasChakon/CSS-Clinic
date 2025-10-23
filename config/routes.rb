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

    resources :mensajes, only: [:index, :create]
    resources :resenas, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :horarios, only: [:index, :new, :create, :edit, :update, :destroy]

  authenticated :user do
    root "home#index"
  end

  unauthenticated :user do
    root "home#unregistered", as: :user_unregistered
  end  

  namespace :admin do
    root 'dashboard#index'
    get 'panel', to: 'panel#index'        
    post 'panel/hacer_medico/:id', to: 'panel#hacer_medico', as: 'hacer_medico'
    resources :doctores
    resources :reservas
  end 

  resources :reservas do
    resources :mensajes, only: [:index, :create]
  end
end