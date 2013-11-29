Headlines::Application.routes.draw do

  resources :headlines do
    collection do
      get :save
      get :best
      post :generate
    end
    member do
      get :vote
    end
  end

  get "best", to: "headlines#best"
  get "generator", to: "headlines#generator"

  root to: redirect("best")

end
