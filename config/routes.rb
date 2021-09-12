Rails.application.routes.draw do
  resource :iqdb, controller: "iqdb", only: [] do
    collection do
      get :index
      post :search
    end
  end
  root to: "static#home"
end
