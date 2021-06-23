Rails.application.routes.draw do
  get :health, to: ->(_env) { [200, {}, ["ok"]] }

  get '/auth/auth0/callback', to: 'auth0#callback'
  get '/auth/failure',        to: 'auth0#failure'
  get '/auth/logout',         to: 'auth0#logout'

  resources :shorts, path: '/', only: %i[create destroy show]
end
