Rails.application.routes.draw do
  root 'static_pages#home'
  resources :tasks do
    get :myself, on: :collection
    get :edit_assignment, on: :member
    patch :update_assignment, on: :member
  end
  devise_for :users
end
