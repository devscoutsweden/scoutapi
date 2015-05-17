Scoutapi::Application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :activities, only: [:index, :show, :create, :update, :destroy] do
        get 'rating', to: 'ratings#show'
        post 'rating', to: 'ratings#create'
        delete 'rating', to: 'ratings#destroy'
        post 'related/auto_generated', to: 'related_activities#set_auto_generated'
        resources :related, controller: 'related_activities', only: [:index, :create, :destroy]
      end
      resources :references, only: [:index, :show, :create, :update, :destroy]
      resources :system_messages, only: [:index, :show, :create, :update, :destroy]
      resources :media_files, only: [:index, :show, :create, :update, :destroy] do
        get 'file', to: 'media_files#handle_resized_image_request'
      end
      #post 'users', to: 'users#create'
      get 'users/profile', to: 'users#profile'
      put 'users/profile', to: 'users#update_profile'
      resources :users, only: [:index, :show, :update]
      get 'all_api_keys', to: 'users#all_api_keys'
      get 'favourites', to: 'favourites#index'
      put 'favourites', to: 'favourites#update'
      get 'system/ping', to: 'system#ping'
      get 'system/roles', to: 'system#roles'
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
