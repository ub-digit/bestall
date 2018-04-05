Rails.application.routes.draw do

  namespace :api, :defaults => {:format => :json} do
    resources :session
    resources :biblios
    resources :reserves

    get 'locations', to: 'locations#index'
    get 'loan_types', to: 'loan_types#index'

    get 'users/current', to: 'users#current_user'

    post 'print', to: 'print#create'

    # Config API
    get 'config/:id', to: 'config#show'

    # Endpoint för Libris exemplarinfo
    get 'libris', to: 'libris#index'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount_ember_app :frontend, to: "/"
end
