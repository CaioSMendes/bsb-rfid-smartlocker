class WelcomeController < ApplicationController
  def index
    puts "Endereço IP do Host do PostgreSQL: #{ENV['POSTGRES_IP']}"
    @admin_lockers_count = Keylocker.count # Quantidade total de lockers para o administrador

    if current_user.admin?
      # Se o usuário for administrador, busca todos os lockers
      @admin_keylockers_count = Keylocker.count
      @admin_users_count = User.count
      @admin_employees_count = Employee.count
    else
      # Se não for administrador, busca os lockers relacionados ao usuário
      @user_keylockers_count = current_user.keylockers.count
      @user_employees_count = Employee.where(user_id: current_user.id).count
    end
  end
end
