Rails.application.routes.draw do
  resource :iqdb, controller: "iqdb", only: [] do
    collection do
      get :index
      post :search
    end
  end
  resources :artists, only: %i[index new create show]
  resource :session, only: %i[create destroy]
  resource :static, controller: "static", only: [] do
    collection do
      get :about
      get :contact
      get :home
    end
  end
  root to: "static#home"
end
