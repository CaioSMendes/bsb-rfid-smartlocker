# config/initializers/email_settings.rb
class EmailSettingsLoader
    def self.load
      settings = EmailSetting.last
      if settings
        ActionMailer::Base.delivery_method = :smtp
        ActionMailer::Base.smtp_settings = {
          address:              settings.address,
          port:                 settings.port,
          domain:               settings.domain,
          user_name:            settings.user_name,
          password:             settings.password,
          authentication:       settings.authentication,
          enable_starttls_auto: settings.enable_starttls_auto
        }
      end
    end
  end
  
  # Carregar as configurações ao iniciar a aplicação
  #EmailSettingsLoader.load
  