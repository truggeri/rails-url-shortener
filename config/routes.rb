Rails.application.routes.draw do
  get :health, to: ->(_env) { [200, {}, ["ok"]] }

  resources :shorts, path: '/', only: %i[create destroy show]
end
