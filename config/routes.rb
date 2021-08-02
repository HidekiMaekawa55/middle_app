Rails.application.routes.draw do
  root 'static_pages#home'
  resources :tasks do
    get :myself, on: :collection
  end
  devise_for :users
end
