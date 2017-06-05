Rails.application.routes.draw do
  root 'homes#index'

  resources :homes, only: [:index]
  resources :users
  # 考勤
  namespace :attendance do
    resources :records
    resources :units do
      post :import, on: :member
      post :export, on: :collection
    end
  end
end
