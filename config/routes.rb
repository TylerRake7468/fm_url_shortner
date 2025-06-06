Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :short_urls, only: [:create] do
        member do
          patch :deactivate
        end

        collection do
          get :analytics
        end
      end
    end
  end

  get '/:short_code', to: 'redirect#show', as: :redirect

end
