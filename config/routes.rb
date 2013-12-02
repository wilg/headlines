Headlines::Application.routes.draw do

  resources :headlines do
    collection do
      get :best
    end
    member do
      post :vote
    end
  end

  get "best", to: "headlines#best"
  get "game", to: "headlines#game"

  get "generator", to: "generator#index"
  post "generator/generate", to: "generator#generate", as: :generate
  get "generator/save", to: "generator#save", as: :save

  root to: redirect("best")

end
