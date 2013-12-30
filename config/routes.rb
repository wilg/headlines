Headlines::Application.routes.draw do

  devise_for :users

  resources :comments

  resources :headlines do
    resources :comments
    collection do
      get :best
    end
    member do
      post :vote
    end
  end

  resources :source_headlines

  resources :users do
    resources :headlines
    resources :votes
    resources :comments
  end

  get "leaderboard", to: "users#index"

  get "best", to: "headlines#best"

  get "generator", to: "generator#index"
  post "generator/save", to: "generator#save", as: :save

  root to: redirect("best")

end
