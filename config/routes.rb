Rails.application.routes.draw do
  get :health, to: ->(_env) { [200, {}, ["ok"]] }

  resources(:shorts, path: '/', only: %i[create destroy show]) do
    collection do
      get('/count', to: 'shorts#count')
      post('/suggestion', to: 'shorts#suggest')
    end
  end
end
