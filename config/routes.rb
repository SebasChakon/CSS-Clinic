# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }
  get 'render/index'

  get 'up' => 'rails/health#show', as: :rails_health_check

  # Rutas de reservas
  resources :reservas, only: %i[index show edit update new create] do
    collection do
      get 'farmacias_cercanas'
    end

    member do
      get :cancelar
      get :confirmar
      get :completar
    end

    resources :mensajes, only: %i[index create]
    resources :resenas, only: %i[new create edit update destroy]
  end

  resources :horarios, only: %i[index new create edit update destroy]

  authenticated :user do
    root 'home#index'
  end

  unauthenticated :user do
    root 'home#unregistered', as: :user_unregistered
  end

  namespace :admin do
    root 'dashboard#index'
    get 'panel', to: 'panel#index'
    post 'panel/hacer_medico/:id', to: 'panel#hacer_medico', as: 'hacer_medico'
    resources :doctores
    resources :reservas
  end

  resources :reservas do
    resources :mensajes, only: %i[index create]
  end
end
