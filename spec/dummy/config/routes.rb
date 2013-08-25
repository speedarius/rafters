Rails.application.routes.draw do
  mount Rafters::Engine => "/rafters"

  resources :foos
end
