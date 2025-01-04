class ManagerUsersController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_user, only: [:toggle_role, :toggle_finance, :set_user_role, :set_admin_role, :destroy]
    skip_before_action :verify_authenticity_token, only: [:toggle_role, :toggle_finance]
    skip_before_action :authenticate_user!, only: [:toggle_role, :toggle_finance]

    def index
        @users = User.all.paginate(page: params[:page], per_page: 10)
    end

    def toggle_role
        # Verifica se o usuário que está tentando alterar a role é diferente do usuário atual
        if current_user.id != @user.id
          new_role = (@user.role == 'admin') ? 'user' : 'admin'
          @user.update(role: new_role)
          render json: { status: 'success', new_role: new_role }
        else
          render json: { status: 'error', message: 'Você não pode alterar sua própria role.' }, status: :unprocessable_entity
        end
    end

    def toggle_finance
      # Verifica se o usuário que está tentando alterar a role é diferente do usuário atual
      if current_user.id != @user.id
        @user.finance = (@user.finance == 'adimplente') ? 'inadimplente' : 'adimplente'
        @user.save
        render json: { finance: @user.finance }, status: :ok
      else
        render json: { status: 'error', message: 'Você não pode alterar sua própria situação financeira.' }, status: :unprocessable_entity
      end
    end

    def destroy
        if @user != current_user
            @user = User.find(params[:id])
            @user.destroy
            redirect_to manager_users_index_path, notice: 'Usuário excluído com sucesso.'
        else
          redirect_to manager_users_index_path, alert: 'Você não pode excluir a si mesmo.'
        end
    end
    
    
    private

    def authenticate_admin!
      unless current_user.admin?
        flash[:alert] = "Acesso não autorizado."
        redirect_to root_path
      end
    end

    def set_user
        @user = User.find(params[:id])
    end

end
