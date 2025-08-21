class EmployeesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:toggle_and_save_status, :reset_pin, :send_sms_with_new_pin, :destroy]
  skip_before_action :authenticate_user!, only: [:toggle_and_save_status, :reset_pin, :send_sms_with_new_pin, :destroy]
  before_action :set_employee, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :set_mailer_settings


  # GET /employees or /employees.json
  def index
    if current_user.admin?
      #@employees = Employee.all
      @employees = Employee.includes(:user).all.paginate(page: params[:page], per_page: 9)
      @users = User.all.includes(:keylockers, employee: :keylocker).paginate(page: params[:page], per_page: 9)
    else
      @employees = Employee.where(user_id: current_user.id).paginate(page: params[:page], per_page: 9)
    end
  end

  # GET /employees/1 or /employees/1.json
  def show
    @employee = Employee.find(params[:id])
  end

  # GET /employees/new
  def new
    @employee = Employee.new
    @employee.workdays.build # Constrói um workday vazio para o formulário
  end

  # GET /employees/1/edit
  def edit
  end

  def create
    @employee = Employee.new(employee_params)
    @employee.user = current_user
    @employee.keylockers = current_user.keylockers
    @employee.PIN = generate_unique_pin
  
    respond_to do |format|
      if @employee.save
        send_sms(@employee.phone, "Brasilia RFID ! Para concluir o cadastro digite o seu PIN de de validacao: #{@employee.PIN}")
        #EmployeePinMailer.send_pin(@employee).deliver_now #ENVIA EMAIL
        format.html { redirect_to employee_url(@employee), notice: "Funcionário foi criado com sucesso." }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # PATCH/PUT /employees/1 or /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to employee_url(@employee), notice: "Funcionário foi atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1 or /employees/1.json
  def destroy
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to employees_url, notice: "Funcionário foi deletado com sucesso." }
      format.json { head :no_content }
    end
  end

  def reset_pin
    @employee = Employee.find(params[:id]) # Certifique-se de encontrar a instância correta pelo ID
    if @employee
      @employee.PIN = generate_unique_pin
      if @employee.save
        send_sms_with_new_pin(params[:phone], @employee.PIN)
        render json: { message: 'Novo PIN resetado e enviado por SMS com sucesso!' }
      else
        render json: { error: 'Erro ao resetar o novo PIN.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Funcionário não encontrado.' }, status: :not_found
    end
  end
 
  def toggle_and_save_status
    @employee = Employee.find(params[:id])
    @employee.update(status: (@employee.status == 'bloqueado' ? 'desbloqueado' : 'bloqueado'))
    respond_to do |format|
      format.json { render json: { status: @employee.status } }
    end
  end

  def send_sms(phone, message)
    # Pega o telefone do funcionário
    puts "Telefone do funcionário: #{phone}"
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

  def send_sms_notification
    @employee = Employee.find(params[:id])
    phone = @employee.phone
    nome = @employee.name
    puts "Telefone do funcionário: #{phone}"
    puts "Nome do funcionário: #{nome}"

    Sendsms.all.each do |sms|
      puts "SMS Entry:"
      puts "  User: #{sms.user}"
      puts "  Password: #{sms.password}"
      puts "  URL: #{sms.url}"
      puts "  Hash Seguranca: #{sms.hashSeguranca}"

      message = "Brasilia RFID ! Ola #{nome} chegou algo no locker para voce."
      puts "Message Envio: #{message}"
      encoded_message = ERB::Util.url_encode(message)
      url = "#{sms.url}?user=#{sms.user}&password=#{sms.password}&destinatario=#{phone}&msg=#{encoded_message}&hashSeguranca=#{sms.hashSeguranca}"

      begin
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        if response.code.to_i == 200
          flash[:notice] = "SMS enviado com sucesso!"
        else
          flash[:alert] = "Falha no envio do SMS. Código: #{response.code}"
        end
      rescue StandardError => e
        flash[:alert] = "Erro ao enviar SMS: #{e.message}"
      end
    end

    redirect_to employees_url
  end

  private

    def generate_unique_pin
      loop do
        pin = generate_pin
        return pin unless Employee.exists?(PIN: pin)
      end
    end

    def generate_pin
      characters = ('0'..'9').to_a + ('A'..'D').to_a
      pin = (0...6).map { characters.sample }.join
    end

    def send_sms_with_new_pin(phone, pin)
      puts "Telefone do funcionário: #{phone}"
      puts "Novo PIN gerado: #{pin}"
      sendsms_entries = Sendsms.all
        sendsms_entries.each do |sms|
          puts "SMS Entry:"
          puts "  User: #{sms.user}"
          puts "  Password: #{sms.password}"
          puts "  Message: #{sms.msg}"
          puts "  URL: #{sms.url}"
          puts "  Hash Seguranca: #{sms.hashSeguranca}"

          message = "Brasilia RFID ! Seu novo PIN de acesso: #{pin}"
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

    def set_mailer_settings
      settings = EmailSetting.last
      if settings
        ActionMailer::Base.smtp_settings = {
          address:              settings.address,
          port:                 settings.port,
          user_name:            settings.user_name,
          password:             settings.password,
          authentication:       settings.authentication,
          enable_starttls_auto: settings.enable_starttls_auto,
          tls:                  settings.tls
        }
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def employee_params
      params.require(:employee).permit(
        :name, :email, :lastname, :delivery, :enabled, :companyID, :phone, :cpf, :PIN, :function, :pswdSmartlocker, :cardRFID, :status, :matricula, :operator, :profile_picture,
        workdays_attributes: [:id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start, :end, :enabled, :_destroy]
      ).tap do |whitelisted|
        # Verifica se o parâmetro 'enabled' foi enviado como 'true'
        if params[:enabled] != "true"
          whitelisted[:workdays_attributes]&.each do |_, workday|
            # Substitui campos vazios por valores padrão
            workday[:start] = "00:00" if workday[:start].blank?
            workday[:end] = "00:00" if workday[:end].blank?
    
            # Se os dias não forem marcados, atribui '0'
            workday[:monday] ||= "0"
            workday[:tuesday] ||= "0"
            workday[:wednesday] ||= "0"
            workday[:thursday] ||= "0"
            workday[:friday] ||= "0"
            workday[:saturday] ||= "0"
            workday[:sunday] ||= "0"
    
            # Se o parâmetro 'enabled' não estiver presente ou estiver vazio, define 'enabled' como false
            workday[:enabled] = false if workday[:enabled].blank?
          end
        end
      end
    end
end
