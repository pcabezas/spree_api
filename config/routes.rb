Rails.application.routes.draw do
  # Spree routes
  mount Spree::Core::Engine, at: '/'

  # sidekiq web UI
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Rails.application.secrets.sidekiq_username &&
      password == Rails.application.secrets.sidekiq_password
  end
  mount Sidekiq::Web, at: '/sidekiq'
end

Spree::Core::Engine.add_routes do
  namespace :api do
    namespace :v2 do
      namespace :storefront do
        put '/webpay/payment/init-transaction', to: 'webpay#init_transaction', as: :webpay_init_transaction
        get 'webpay/payment/transaction_result', to: 'webpay#transaction_result', as: :webpay_transaction_result
      end
    end
  end
end
