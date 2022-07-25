# frozen_string_literal: true

require "sidekiq_unique_jobs/web"

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  resource :iqdb, controller: "iqdb", only: [] do
    get :index
    post :search
  end
  resources :artists, only: %i[index new create show destroy edit update] do
    member do
      post :enqueue_all_urls
      post :update_all_iqdb
    end
  end
  resource :static, controller: "static", only: [] do
    get :about
    get :contact
    get :home
  end
  resource :debug, controller: "debug", only: [] do
    get :index
    post :reload_config
    post :generate_spritemap
    post :iqdb_readd
  end
  resources :submission_files, only: %i[show] do
    member do
      post :update_e6_iqdb
      post :add_to_backlog
      delete :remove_from_backlog
    end
    collection do
      get :backlog
    end
  end
  resources :tumblr_imports, only: %i[new create]
  resources :stats, only: :index
  root to: "static#home"
end
