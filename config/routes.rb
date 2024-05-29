Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get '/batches/reddit', to: 'batches#reddit'
  get '/tos', to: 'pages#tos'
  get '/privacy', to: 'pages#privacy'
  get "up" => "rails/health#show", as: :rails_health_check


  # Defines the root path route ("/")
  # root "posts#index"

resources :batches, only: [:update, :edit, :new, :create, :show]
resources :outputs, only: [:index]
get '/download_video', to: 'outputs#download', as: 'download_video'

end
