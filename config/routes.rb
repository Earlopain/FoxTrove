require "sidekiq_unique_jobs/web"

Rails.application.routes.draw do
  # TODO: constraint
  mount Sidekiq::Web, at: "/sidekiq"

  resource :iqdb, controller: "iqdb", only: [] do
    collection do
      get :index
      post :search
    end
  end
  resources :artists, only: %i[index new create show destroy edit update] do
    post :enqueue_all_urls
  end
  resource :session, only: %i[create destroy new]
  resource :static, controller: "static", only: [] do
    collection do
      get :about
      get :contact
      get :home
    end
  end
  resource :debug, controller: "debug", only: [] do
    get :index
    post :reload_config
    post :generate_spritemap
    post :seed_db
    post :iqdb_readd
  end
  resources :users, only: %i[show]
  resources :submission_files, only: %i[show] do
    post :update_e6_iqdb
  end
  resource :backlog, only: %i[create destroy] do
    get :index
  end
  root to: "static#home"
end
