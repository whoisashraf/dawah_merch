Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  root "orders#new"

  resource :order, only: [:new, :create]
  get "order/success/:reference", to: "orders#success", as: :order_success

  post "paystack/webhook", to: "paystack_webhook#create"

  namespace :admin do
    get "/", to: redirect("/admin/dashboard")
    get "dashboard", to: "dashboard#index"
    resource :settings, only: [:show, :update]

    resources :products
    resources :orders, only: [:index, :show, :new, :create, :destroy]
    resources :proofread, only: [:index] do
      member do
        patch :approve
        patch :reject
      end
    end

    get "production", to: "production#index"
    get "pickup", to: "pickup#index"
    patch "pickup/:id/collect", to: "pickup#collect", as: :pickup_collect
  end
end
