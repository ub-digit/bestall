Rails.application.routes.draw do
  resources :posts

  namespace :api, :defaults => {:format => :json} do
    resources :session

    get 'locations', to: 'location#index'

    get 'loantypes', to: 'loantype#index'

    # Config API
    get 'config/:id', to: 'config#cas_url'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount_ember_app :frontend, to: "/"
end
