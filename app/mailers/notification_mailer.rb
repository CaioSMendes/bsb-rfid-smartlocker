# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
    default from: 'no-reply@seuapp.com'
  
    def key_usage_notification(employee, keylocker_info, action)
      @employee = employee
      @keylocker_info = keylocker_info
      @action = action
      @timestamp = Time.current
  
      mail(to: @employee.user.email, subject: 'Notificação de Uso de Chave')
    end
  end
  