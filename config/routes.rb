Headlines::Application.routes.draw do

  resources :headlines do
    collection do
      get :save
      get :best
    end
    member do
      get :vote
    end
  end

  root "headlines#index"

end
