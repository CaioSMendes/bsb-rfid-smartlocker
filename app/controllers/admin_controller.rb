class AdminController < ApplicationController
    #before_action :authenticate_admin! # Certifique-se de que apenas administradores têm acesso

    def index
      @employees = Employee.includes(:user).all
      @users = User.all.includes(:keylockers, employee: :keylocker)
    end

    def dadosuser
      @users = [current_user] # Cria um array contendo apenas o usuário atual
    end
end
