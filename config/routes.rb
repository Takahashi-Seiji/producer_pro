Rails.application.routes.draw do
  devise_for :users
  root 'dashboard#index'
  
  resources :clients
  resources :products
  resources :orders
  resources :order_items
  resources :raw_materials
  resources :expenses
  resources :incomes
  
  get 'dashboard/orders', to: 'dashboard#orders'
  get 'dashboard/inventory', to: 'dashboard#inventory'
  get 'dashboard/clients', to: 'dashboard#clients'
  get 'dashboard/finances', to: 'dashboard#finances'
  get 'dashboard/reports', to: 'dashboard#reports'
  get 'dashboard/calendar', to: 'dashboard#calendar', as: :calendar

  # Analytics routes
  namespace :analytics do
    get 'dashboard', to: 'dashboard#index'
    get 'sales_report', to: 'dashboard#sales_report'
    get 'inventory_report', to: 'dashboard#inventory_report'
    get 'financial_report', to: 'dashboard#financial_report'
    get 'custom_report', to: 'dashboard#custom_report'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
