Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 1) POST /readings -> store readings
  post '/readings', to: 'readings#create'

  # 2) GET /devices/:id/latest_timestamp -> fetch latest timestamp
  get '/devices/:id/latest_timestamp', to: 'devices#latest_timestamp'
 
  # 3) GET /devices/:id/cumulative_count -> fetch cumulative count
  get '/devices/:id/cumulative_count', to: 'devices#cumulative_count'
end
