Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :short_urls, only: [:create]
    end
  end
end
