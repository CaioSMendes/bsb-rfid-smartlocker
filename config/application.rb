require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Smartlocker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.i18n.default_locale = :pt  # Define o idioma padrão
    config.i18n.available_locales = [:en, :pt] # Liste os locais disponíveis
    config.time_zone = 'Brasilia'

    # Configurar o CORS para permitir requisições do ESP32
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'  # Aqui você pode restringir ao IP específico do ESP32 ou um domínio
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          expose: ['Authorization'],
          max_age: 600
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end