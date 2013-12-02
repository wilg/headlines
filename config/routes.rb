Headlines::Application.routes.draw do

  devise_for :users

  resources :headlines do
    collection do
      get :best
    end
    member do
      post :vote
    end
  end

  resources :users do
    collection do
      get :top
    end
    member do
      get :submitted
      get :voted
    end
  end

  get "leaderboard", to: "users#index"

  get "best", to: "headlines#best"

  get "generator", to: "generator#index"
  post "generator/generate", to: "generator#generate", as: :generate
  get "generator/save", to: "generator#save", as: :save

  root to: redirect("best")

end
