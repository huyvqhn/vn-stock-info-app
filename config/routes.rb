Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :tickers, only: [ :index ]

  get "tickers/api_data", to: "tickers#api_data"
  get "tickers/new_view_name", to: "tickers#api_data"
  get "market_groups", to: "market_groups#index"
  get "top_30", to: "market_groups#top_30"
  get "market_groups/update", to: "market_groups#update_group_tickers"
  get "latest_trading_days", to: "latest_trading_days#index"
  get "latest_trading_days/all", to: "latest_trading_days#all", as: :all_latest_trading_days
  get "latest_trading_days/5d", to: "latest_trading_days#aggregate_5d", as: :five_day_aggregate_latest_trading_days

  namespace :api do
    get "stock_prices/import_all", to: "stock_prices#import_all"
    post "stock_prices/import_all_from_groups", to: "stock_prices#import_all_from_groups"
    match "stock_trading_days/import_all", to: "stock_trading_days#import_all", via: [ :get, :post ]
  end

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
