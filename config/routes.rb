Rails.application.routes.draw do
  get :health, to: ->(_env) { [200, {}, ["ok"]] }

  get '/:id', action: :lookup, controller: 'shorts'
end
