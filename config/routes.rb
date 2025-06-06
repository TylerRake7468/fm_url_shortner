Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :short_urls, only: [:create] do
        member do
          patch :deactivate
        end
      end
      get '/short_urls/analytics', to: 'short_urls#analytics'
    end
  end

  get '/:short_code', to: 'redirect#show', as: :redirect

end
