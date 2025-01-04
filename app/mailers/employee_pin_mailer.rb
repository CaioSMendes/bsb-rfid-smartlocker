class EmployeePinMailer < ApplicationMailer
    default from: 'no-reply@seuapp.com'
  
    def send_pin(employee)
      @employee = employee
      @pin = @employee.PIN
      mail(to: @employee.email, subject: 'Seu PIN de Acesso') do |format|
        format.html { render 'send_pin' }
        format.text { render plain: "Seu PIN de acesso é: #{@pin}" }
      end
    end
end
  
