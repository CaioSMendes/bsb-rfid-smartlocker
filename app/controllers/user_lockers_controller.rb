# app/controllers/user_lockers_controller.rb
class UserLockersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users = User.all
    @keylockers = Keylocker.all.paginate(page: params[:page], per_page: 10)
  end

  def assign_keylocker
    @user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])
    if @user && keylocker
      @user.keylockers << keylocker
      redirect_to user_lockers_path, notice: 'Locker atribuído ao usuário com sucesso.'
    else
      redirect_to user_lockers_path, alert: 'Falha ao atribuir locker ao usuário.'
    end
  end

  def remove_keylocker
    Rails.logger.debug "Entrou na função remove_keylocker!"
    puts"user_id: #{params[:user_id]}, keylocker_id: #{params[:keylocker_id]}"


    @user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])

    Rails.logger.debug "user_id: #{params[:user_id]}, keylocker_id: #{params[:keylocker_id]}"
    puts"user_id: #{params[:user_id]}, keylocker_id: #{params[:keylocker_id]}"

    if @user && keylocker
      @user.keylockers.delete(keylocker)
      redirect_to user_lockers_path, notice: 'Locker removido do usuário com sucesso.'
    else
      redirect_to user_lockers_path, alert: 'Falha ao remover locker do usuário.'
    end
  end

  private

  private

  def authenticate_admin!
    unless current_user.admin?
      flash[:alert] = "Acesso não autorizado."
      redirect_to root_path
    end
  end
end
