Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get '/sources/reddit', to: 'sources#reddit'
  get '/sources/video', to: 'sources#video'
  get '/tos', to: 'pages#tos'
  get '/privacy', to: 'pages#privacy'
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
resources :sources, only: [:index]

resources :outputs, only: [:index, :show, :new, :create] do
  resources :schedules, only: [:create]
end
resources :schedules, only: [:index]
get '/download_video', to: 'outputs#download', as: 'download_video'

end
