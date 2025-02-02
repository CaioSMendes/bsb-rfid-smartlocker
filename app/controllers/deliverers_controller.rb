class DeliverersController < ApplicationController
    before_action :set_deliverer, only: %i[show edit update destroy]
    skip_before_action :authenticate_user! # Permite acesso público

    # Tela de cadastro de entregador
    def index
      @deliverers = Deliverer.all
      @deliverers = [] if @deliverers.nil? # Caso não haja entregadores, inicializa como um array vazio
    end

    def new
      @serial = params[:serial]
      @deliverer = Deliverer.new
      @keylockers = Keylocker.all # Carrega todos os keylockers disponíveis. Ajuste conforme necessário.
    end

    def create      
      puts("create")
      @deliverer = Deliverer.new(deliverer_params)
      @deliverer.pin = generate_unique_pin
      if params[:deliverer][:serial].present?
        @deliverer.serial = params[:deliverer][:serial]
      end
      logger.debug("Parametro: #{@deliverer.inspect}")
      if @deliverer.save
        send_sms(@deliverer.phone, "Brasilia RFID ! Para concluir o cadastro digite o seu PIN de de validacao: #{@deliverer.pin}")
        flash[:notice] = "Entregador cadastrado com sucesso!"
        redirect_to deliverers_path
      else
        logger.debug("Errors do cadastro: #{@deliverer.errors.full_messages}")
        render :new
      end
    end
  
    def verify_access
      puts("verify_access")
      identifier = params[:deliverer][:identifier].to_s.strip
      logger.debug("Parametro: #{identifier}")
      @deliverer = Deliverer.find_by("email = ? OR phone = ? OR cpf = ?", identifier, identifier, identifier)
      if @deliverer
        puts("Deu bom :) !")
        redirect_to new_delivery_path(serial: params[:serial])
      else
        @deliverer = Deliverer.new
        puts("Deu ruim :( !")
        flash[:alert] = "Entregador não encontrado!"
        render :new # ou redirecionar para outra página
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

 

    def send_sms(phone, message)
      # Pega o telefone do funcionário
      puts "Telefone do entregador: #{phone}"
      puts "Message Envio: #{message}"
      sendsms_entries = Sendsms.all
        sendsms_entries.each do |sms|
          puts "SMS Entry:"
          puts "  User: #{sms.user}"
          puts "  Password: #{sms.password}"
          puts "  Message: #{sms.msg}"
          puts "  URL: #{sms.url}"
          puts "  Hash Seguranca: #{sms.hashSeguranca}"
          
          encoded_message = ERB::Util.url_encode(message)
          # Monta a URL para o envio do SMS
          url = "#{sms.url}?user=#{sms.user}&password=#{sms.password}&destinatario=#{phone}&msg=#{encoded_message}&hashSeguranca=#{sms.hashSeguranca}"
          puts "Montando a URL do POST: #{url}"
          # Realiza o POST para o serviço de envio
          begin
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)
            # Log do status da requisição
            if response.code.to_i == 200
              puts "SMS enviado com sucesso!"
            else
              puts "Falha no envio do SMS, código de resposta: #{response.code}"
            end
          rescue StandardError => e
            puts "Erro ao enviar SMS: #{e.message}"
          end
        end
    end
  

     # Método para gerar um PIN único
     def generate_unique_pin
      loop do
        pin = generate_pin
        return pin unless Deliverer.exists?(pin: pin)
      end
    end
    
    # Lógica de geração de PIN
    def generate_pin
      characters = ('0'..'9').to_a + ('A'..'D').to_a
      (0...6).map { characters.sample }.join
    end
  
    private

    def normalize_phone(phone)
      phone.gsub(/\D/, '') # Remove todos os caracteres não numéricos
    end
  
    def set_deliverer
      @deliverer = Deliverer.find(params[:id])
    end
  
    def deliverer_params
      params.require(:deliverer).permit(:name, :serial, :lastname, :phone, :email, :cpf, :pin, :keylocker_id)
    end
end  