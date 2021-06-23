# https://auth0.com/docs/quickstart/webapp/rails/01-login#add-an-auth0-controller
class Auth0Controller < ApplicationController
  def callback
    auth_info = request.env['omniauth.auth']
    session[:userinfo] = auth_info['extra']['raw_info']

    binding.pry

    render(plain: 'ok', status: :ok)
  end

  def failure
    @error_msg = request.params['message']
  end

  def logout
  end
end