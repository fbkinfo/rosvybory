require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# load config
AppConfig = YAML.load_file('config/config.yml')
# Override config options by correct environment
env_options = AppConfig.delete(Rails.env)
AppConfig.merge!(env_options) unless env_options.nil?

module Rosvibory
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru
    config.i18n.locale = :ru

    #Отключить восстановление пароля и показать вместо формы восстановления информацию о том, как можно восстановить пароль
    config.disable_password_recovery = true
  end
end
