# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine, at: "/good_job"

  resource :iqdb, controller: "iqdb", only: [] do
    get :index
    post :search
  end
  resources :artists, only: %i[index new create show destroy edit update] do
    member do
      post :enqueue_all_urls
    end
    collection do
      post :enqueue_everything
    end
  end
  resources :artist_urls, only: %i[show] do
    member do
      post :enqueue
    end
  end
  resources :submission_files, only: %i[index show] do
    member do
      post :update_e6_posts
      put :modify_backlog
      put :modify_hidden
    end
    collection do
      get :backlog
      get :hidden
      put :hide_many
      put :backlog_many
      put :enqueue_many
      post :update_matching_e6_posts
    end
  end
  resources :log_events, only: %i[index show]
  resources :archive_imports, only: %i[new create]
  resources :stats, only: :index
  root to: "artists#index"
end
