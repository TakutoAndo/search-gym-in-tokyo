Rails.application.routes.draw do
  root "gyms#index"
  resources :gyms, only: [:index, :show]

  namespace :admin do
    resources :gyms
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
