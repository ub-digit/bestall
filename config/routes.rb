Rails.application.routes.draw do
	root to: 'root#index'
	mount_ember_app :frontend, to: "/"
end
