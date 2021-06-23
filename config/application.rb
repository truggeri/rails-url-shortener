require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module RailsUrlShortener
  class Application < Rails::Application
    config.load_defaults(6.1)
    config.api_only = true
    config.middleware.use(ActionDispatch::Session::CacheStore)
    config.action_dispatch.session_store(:cache_store, key: '_url_shortener_session')
  end
end
