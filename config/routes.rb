Rails.application.routes.draw do

  namespace :api, :defaults => {:format => :json} do
    resources :session
    resources :bib_items
    resources :borrowers

    get 'locations', to: 'location#index'
    get 'loantypes', to: 'loantype#index'

    # Config API
    get 'config/:id', to: 'config#cas_url'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount_ember_app :frontend, to: "/"
end
