class SendsmsController < ApplicationController
    def create
      @sendsms = Sendsms.new(sendsms_params)
      if @sendsms.save
        render json: { message: "SMS salvo com sucesso!" }, status: :created
      else
        render json: { errors: @sendsms.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    # Permite apenas os parâmetros necessários para evitar problemas de segurança
    def sendsms_params
      params.require(:sendsms).permit(:user, :password, :hashSeguranca, :msg)
    end
end  