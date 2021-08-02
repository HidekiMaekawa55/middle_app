Rails.application.routes.draw do
  get 'tasks/new'
  get 'tasks/edit'
  get 'tasks/show'
  get 'tasks/index'
  root 'static_pages#home'
  devise_for :users
end
