class DeliverersController < ApplicationController
    before_action :set_deliverer, only: %i[show edit update destroy]
  
    # Tela de cadastro de entregador
    def new
      @deliverer = Deliverer.new
      @keylockers = Keylocker.all
    end
  
    # Criação do entregador
    def create
      @deliverer = Deliverer.new(deliverer_params)
      if @deliverer.save
        flash[:notice] = "Entregador cadastrado com sucesso!"
        redirect_to deliverers_path
      else
        flash[:alert] = "Erro ao cadastrar entregador."
        render :new
      end
    end
  
    # Verificar se o entregador existe
    def verify
      @deliverer = Deliverer.find_by(email: params[:email]) || Deliverer.find_by(phone: params[:phone]) || Deliverer.find_by(cpf: params[:cpf])
      
      if @deliverer
        render :show_verification
      else
        flash[:alert] = "Entregador não encontrado!"
        redirect_to new_deliverer_path
      end
    end

    def check
      @keylocker = Keylocker.find_by(serial: params[:serial])
  
      if @keylocker
        # Serial encontrado, renderiza o formulário
        @deliverer = Deliverer.new
        render :check
      else
        # Serial não encontrado, redireciona ou exibe mensagem de erro
        render json: { message: "Entregador não encontrado!" }, status: :not_found
      end
    end
  
    private
  
    def set_deliverer
      @deliverer = Deliverer.find(params[:id])
    end
  
    def deliverer_params
      params.require(:deliverer).permit(:name, :lastname, :phone, :email, :cpf, :password, :keylocker_id)
    end
end  