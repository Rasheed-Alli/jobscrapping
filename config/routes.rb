Rails.application.routes.draw do
  root "jobs#index"

  get "/jobs", to: "jobs#index"
  get "/jobs/:id", to: "jobs#show"
end
