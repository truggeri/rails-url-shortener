# https://auth0.com/docs/quickstart/webapp/rails/01-login#initialize-auth0-configuration

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    ENV['AUTH0_CLIENT_ID'],
    ENV['AUTH0_CLIENT_SECRET'],
    ENV['AUTH0_DOMAIN'],
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile'
    },
    provider_ignores_state: true
  )

  configure do |config|
    config.request_validation_phase do
      nil
    end
  end
end