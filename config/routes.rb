Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get '/batches/reddit', to: 'batches#reddit'
  get '/tos', to: 'pages#tos'
  get '/privacy', to: 'pages#privacy'
  get "up" => "rails/health#show", as: :rails_health_check

  resources :batches, only: [:update, :edit, :new, :create, :show]

  resources :outputs, only: [:index, :show, :new, :create] do
    resources :schedules, only: [:create]
  end
  resources :schedules, only: [:index]
  get '/download_video', to: 'outputs#download', as: 'download_video'
end
