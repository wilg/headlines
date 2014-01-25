Headlines::Application.routes.draw do

  # Legacy redirects for URLs that are commonly in use
  get '/headlines/best' => redirect('/')
  get '/best(/today)' => redirect('/')

  devise_for :users

  resources :comments

  resources :headlines do
    resources :comments
    collection do
      get :random
    end
    member do
      post :vote
      get :reconstruct
    end
  end

  resources :source_headlines
  resources :sources

  resources :users do
    resources :headlines
    resources :votes
    resources :comments
  end

  get 'paper', to: "headlines#newspaper"

  get "leaderboard", to: "users#index"

  get "hot", to: "headlines#index", order: :trending, user_id: nil
  get "recent", to: "headlines#index", order: :new, user_id: nil

  get "generator", to: "generator#index"
  post "generator/save", to: "generator#save", as: :save

  get 'best/:timeframe', to: 'headlines#index'

  root to: "headlines#index"

end
