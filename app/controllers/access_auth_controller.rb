require 'net/http'
require 'uri'
require 'erb'

class AccessAuthController < ApplicationController
    skip_before_action :authenticate_user! # Permite acesso público
    skip_before_action :verify_authenticity_token, only: [:resend_pin]

    def index
      serial = params[:serial]
      @keylocker = Keylocker.find_by(serial: serial)
  
      unless @keylocker
        render plain: 'Locker não encontrado', status: :not_found
      end
    end

    def resend_pin
      serial = params[:serial]
      puts "Serial recebido no verify: #{serial}"
      @keylocker = Keylocker.find_by(serial: serial)
      if @keylocker
        puts "Locker encontrado: #{@keylocker.nameDevice} (Serial: #{@keylocker.serial})"
        employee = @keylocker.employees.first
        if employee
          puts "Funcionário encontrado: #{employee.name}, Telefone: #{employee.phone}"
          new_pin = generate_unique_pin
          employee.update!(PIN: new_pin)
          puts "Novo PIN gerado: #{new_pin}"
          log_sms_details(employee, new_pin)
          render json: { message: 'Novo PIN enviado com sucesso!' }, status: :ok
        else
          puts "Nenhum funcionário encontrado para o locker."
          render json: { message: 'Nenhum funcionário encontrado para este locker.' }, status: :not_found
        end
      else
        puts "Locker não encontrado."
        render json: { message: 'Locker não encontrado.' }, status: :not_found
      end
    end
    
    def log_sms_details(employee, new_pin)
      # Pega o telefone do funcionário
      phone = employee.phone
      puts "Telefone do funcionário: #{phone}"
    
      # Busca os dados da tabela `sendsms`
      sendsms_entries = Sendsms.all
      sendsms_entries.each do |sms|
        puts "SMS Entry:"
        puts "  User: #{sms.user}"
        puts "  Password: #{sms.password}"
        puts "  Message: #{sms.msg}"
        puts "  URL: #{sms.url}"
        puts "  Hash Seguranca: #{sms.hashSeguranca}"
    
        # Substitui placeholders na mensagem pelo PIN gerado
        message = "#{sms.msg} #{new_pin}"
        puts "  Message Envio: #{message}"
        encoded_message = ERB::Util.url_encode(message)
        # Monta a URL para o envio do SMS
        url = "#{sms.url}?user=#{sms.user}&password=#{sms.password}&destinatario=#{phone}&msg=#{encoded_message}&hashSeguranca=#{sms.hashSeguranca}"
        puts "Montando a URL do POST: #{url}"
        # Realiza o POST para o serviço de envio
        begin
          uri = URI.parse(url)
          response = Net::HTTP.get_response(uri)
    
          # Log do status da requisição
          puts "Resposta do envio do SMS: #{response.code} - #{response.body}"
        rescue StandardError => e
          puts "Erro ao enviar SMS: #{e.message}"
        end
      end
    
      # Exibe o PIN gerado
      puts "Novo PIN gerado: #{new_pin}"
    end
  
    def verify
      serial = params[:serial]
      puts "Serial recebido no verify: #{serial}"
    
      @keylocker = Keylocker.find_by(serial: serial)
      if @keylocker
        puts "Locker encontrado: #{@keylocker.inspect}"
    
        user_input = params[:user_input]
        puts "Input do usuário: #{user_input}"
    
        # Verifica se existe um funcionário associado ao locker com o email, telefone ou CPF fornecido
        @employee = Employee.joins(:employees_keylockers)
                            .where('employees.email = :input OR employees.phone = :input OR employees.cpf = :input', input: user_input)
                            .where(employees_keylockers: { keylocker_id: @keylocker.id })
                            .first
    
        if @employee
          puts "Funcionário encontrado: #{@employee.inspect}"
    
          # Gera e atualiza o PIN do funcionário
          new_pin = generate_unique_pin
          @employee.update!(PIN: new_pin)
          puts "Novo PIN gerado para o funcionário: #{new_pin}"
    
          # Chama o método para logar os detalhes
          log_sms_details(@employee, new_pin)
    
          # Redireciona para a página de sucesso
          flash[:notice] = "Acesso autorizado."
          puts "Redirecionando para confirm_pin com serial: #{serial}"
          redirect_to confirm_pin_path(serial: serial), notice: 'Usuário encontrado!' and return
        else
          puts "Usuário não tem acesso ao locker"
          flash[:error] = "Usuário não tem acesso ao locker. Por favor, tente novamente."
          render :index and return
        end
      else
        puts "Locker não encontrado."
        flash[:error] = "Locker não encontrado."
        render :index and return
      end
    end

    def confirm_pin
      serial = params[:serial]
      @keylocker = Keylocker.find_by(serial: serial)
    
      unless @keylocker
        flash[:error] = "Locker não encontrado."
        redirect_to confirm_pin_path(serial: serial), notice: 'Locker não encontrado!' and return
      end
    end
    
    
    def validate_pin
      serial = params[:serial]
      pin = params[:PIN]

      puts "validate pin"
      puts "Serial recebido: #{serial}"
      puts "PIN recebido: #{pin}"
      
      @keylocker = Keylocker.find_by(serial: serial)
      if @keylocker.nil?
        puts "Locker não encontrado com o serial #{serial}."
        flash[:error] = "Locker não encontrado."
        redirect_to confirm_pin_path and return
      else
        puts "Locker encontrado: #{@keylocker.inspect}"
      end
      # Verifica se o PIN corresponde a um funcionário associado ao locker
      @employee = @keylocker.employees.find_by(PIN: pin)
      if @employee
        puts "Funcionário encontrado: Nome: #{@employee.name}, Email: #{@employee.email}, PIN: #{@employee.PIN}"
        Rails.logger.info "Acesso permitido para o Employee: #{@employee.name}, Email: #{@employee.email}"
        flash[:notice] = "PIN válido! Acesso permitido para #{@employee.name}."
        puts "Redirecionando para confirm_pin com serial: #{serial}"
        #redirect_to access_auth_success_page_path(serial: serial)
        redirect_to access_auth_success_page_path(serial: serial, pin: pin)
      else
        puts "PIN inválido ou funcionário não associado ao locker #{serial}."
        Rails.logger.info "PIN inválido ou funcionário não associado ao locker #{@keylocker.serial}"
        flash[:error] = "PIN inválido. Tente novamente."
      end
    end

    def success_page
      serial = params[:serial] # Obtém o serial dos parâmetros
      pin = params[:pin]       # Obtém o PIN dos parâmetros
    
      puts "Serial recebido: #{serial}"
      puts "PIN recebido: #{pin}"
    
      @keylocker = Keylocker.find_by(serial: serial)
    
      if @keylocker
        puts "Locker encontrado: #{@keylocker.nameDevice} (Serial: #{@keylocker.serial})"
        
        @employees = @keylocker.employees
    
        if @employees.any?
          @employee = @employees.first
          puts "Funcionário encontrado: #{@employee.inspect}" # Loga detalhes do funcionário
        else
          puts "Nenhum funcionário associado ao locker."
          @employee = nil
        end
      else
        puts "Locker não encontrado."
        @keylocker = nil
        @employees = []
      end
    end
    
    def select_niche
      id = params[:id]
      object = params[:object]
      pin = params[:pin]
      serial = params[:serial]
    
      puts "ID do nicho selecionado: #{id}"
      puts "Objeto do nicho: #{object}"
      puts "PIN válido: #{pin}"
      puts "Serial recebido: #{serial}"
    
      # Localizar o nicho selecionado
      keylocker_info = Keylockerinfo.find_by(id: id)
    
      if keylocker_info && keylocker_info.empty == 0
        # Obter o empregado autenticado (usando PIN)
        employee = Employee.find_by(PIN: pin)
    
        if employee
          # Atualizar o status do nicho
          keylocker_info.update(empty: 1)
    
          # Registrar a associação (se necessário)
          unless employee.keylockers.include?(keylocker_info.keylocker)
            employee.keylockers << keylocker_info.keylocker
          end

          # Criar um log de uso da chave (retirada)
          action = "entrada" # ou defina como "Entrada no Locker" caso seja a devolução do item
          log = Log.create(
            employee_id: employee.id,
            action: action,
            key_id: keylocker_info.keylocker.serial,
            locker_name: keylocker_info.keylocker.nameDevice,
            timestamp: Time.now,
            status: "Ocupado",
            comments: "Nicho #{id} ocupado por #{employee.email}"
          )
        
          render json: {
            message: "Nicho #{id} selecionado com sucesso!",
            object: object,
            employee: employee.email,
            nicho_status: "Agora ocupado por #{employee.email}"
          }, status: :ok
        else
          render json: { error: "Empregado não encontrado ou PIN inválido." }, status: :unprocessable_entity
        end
      else
        render json: { error: "Nicho indisponível ou inexistente." }, status: :unprocessable_entity
      end
    end
  
    # Método para gerar um PIN único
    def generate_unique_pin
      loop do
        pin = generate_pin
        return pin unless Employee.exists?(PIN: pin)
      end
    end
    
    # Lógica de geração de PIN
    def generate_pin
      characters = ('0'..'9').to_a + ('A'..'D').to_a
      (0...6).map { characters.sample }.join
    end
end
  