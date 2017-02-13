Rails.application.routes.draw do

  namespace :api, :defaults => {:format => :json} do
    resources :session
    resources :biblios

    get 'locations', to: 'locations#index'
    get 'loan_types', to: 'loan_types#index'

    # Config API
    get 'config/:id', to: 'config#cas_url'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount_ember_app :frontend, to: "/"
end
