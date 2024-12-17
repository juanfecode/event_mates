Rails.application.routes.draw do
  get "favorites/create"
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  get "/events/:id/groups/new", to: "groups#new", as: "new_group"
  post "/groups", to: "groups#create"


  # juanfe
  resources :events, only: %i[index show new create update] do
    resources :favorite_events, only: %i[create destroy]
  end
  resources :questions, only: %i[index create]


  # kyle
  get "profiles/:id", to: "profiles#show", as: "profile"
  get "tags", to: "tags#index", as:"tags"
  post "tags/:tag_id/add_user_tag", to: "tags#add_user_tag", as: "add_user_tag"
  delete "tags/:tag_id/remove_user_tag", to: "tags#remove_user_tag", as: "remove_user_tag"
  post "tags/:tag_id/add_event_tag", to: "tags#add_event_tag", as: "add_event_tag"
  delete "tags/:tag_id/remove_event_tag", to: "tags#remove_event_tag", as: "remove_event_tag"


  # gaston
  get "/groups/:id", to: "groups#show", as: "group"
  get "/groups/:id/admin", to:"groups#admin", as: "admin_group"
  get "/groups/:id/invite", to: "groups#invite", as: "invite_group"
  post "/groups/:id/invite", to: "groups#invite_requests", as: "invite_requests"
  get "/requests", to: "requests#index"
  delete "/requests/:id/cancel_request", to: "requests#cancel_request", as: "cancel_request"
  patch "/requests/:id/reject_request", to: "requests#reject_request", as: "reject_request"
  patch "/requests/:id/remove_member", to: "requests#remove_member", as: "remove_member"
  post "/groups/:id/requests", to: "requests#ask_to_join", as: "ask_to_join"
  patch "/groups/:id/requests", to: "requests#ask_to_rejoin", as: "ask_to_rejoin"
  get "/groups/:id/request_form", to: "requests#request_form", as: "request_form"
  patch "/requests/:id/approve_request", to: "requests#approve_request", as: "approve_request"

  get "/groups/:id/messages", to: "group_messages#index", as: "messages"
  post "/groups/:id/messages", to: "group_messages#create_message", as: "create_message"

  get "/about_us", to: "pages#about_us"
  get "/policies", to: "pages#policies"
  get "/contact", to: "pages#contact"

end
