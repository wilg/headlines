Headlines::Application.routes.draw do

  # Legacy redirects for URLs that are commonly in use
  get '/headlines/best' => redirect('/')
  get '/best(/today)' => redirect('/')

  devise_for :users, controllers: { registrations: "registrations" }

  resources :comments

  resources :headlines, except: [:show, :update, :edit, :destroy] do
    resources :comments
    collection do
      get :random
    end
    member do
      post :vote
      get :reconstruct
      get :pick_photo
      get :tweet_from_bot
      post :update_photo
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

  get "leaderboard(/:timeframe)", to: "users#index", as: :leaderboard

  get "trending", to: "headlines#index", order: :trending, user_id: nil
  get "hot", to: "headlines#index", order: :hot, user_id: nil
  get "recent", to: "headlines#index", order: :new, user_id: nil

  get "generator", to: "generator#index"
  post "generator/save", to: "generator#save", as: :save

  get 'best/:timeframe', to: 'headlines#index'

  resources :headlines, only: [:show, :destroy], path: "/"
  get '/headlines/:id' => redirect('/%{id}')

  root to: "headlines#index"

end
