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
  resources :artist_urls, only: [] do
    member do
      post :enqueue
    end
  end
  resource :debug, controller: "debug", only: [] do
    get :index
    post :reload_config
    post :generate_spritemap
    post :iqdb_readd
  end
  resources :submission_files, only: %i[index show] do
    member do
      post :update_e6_iqdb
      put :modify_backlog
      put :modify_hidden
    end
    collection do
      get :backlog
      get :hidden
    end
  end
  resources :log_events, only: %i[index show]
  resources :tumblr_imports, only: %i[new create]
  resources :stats, only: :index
  root to: "artists#index"
end
