class DeliveriesController < ApplicationController
  skip_before_action :authenticate_user! # Permite acesso público

    def new
      @delivery = Delivery.new
      @deliverers = Deliverer.all
      @employees = Employee.all
    end

    # Criação da encomenda
    def create
      # Acessando o serial diretamente da URL
      serial = params[:serial]
      Rails.logger.debug "Parâmetros recebidos create: #{params.inspect}"

      # Aqui você pode usar o serial para associá-lo ao delivery ou realizar outras ações
      @delivery = Delivery.new(delivery_params)
      @delivery.serial = serial  # Supondo que você tenha uma coluna 'serial' no seu modelo Delivery
      
      if @delivery.save
        redirect_to some_path # Redirecionamento após sucesso
      else
        render :new # Exibir o formulário novamente em caso de erro
      end
    end

    def search_employee_by_phone_or_email
      query = params[:query].to_s.strip # Remove espaços em branco e garante que seja uma string
    
      # Verifica se a query está vazia
      if query.blank?
        render plain: "<p class='text-danger'>Por favor, insira um telefone ou e-mail.</p>", status: :unprocessable_entity
        return
      end
    
      # Tenta buscar pelo telefone primeiro
      @employee = search_employee_by_phone(query)
      
      # Se não encontrar pelo telefone, tenta buscar pelo e-mail
      @employee ||= search_employee_by_email(query)
    
      # Debug: Exibe no log qual foi a consulta realizada
      puts "Consulta realizada para: #{query}"
    
      respond_to do |format|
        if @employee
          format.html { render partial: 'employee_details', locals: { employee: @employee } } # Renderiza o parcial com as informações do funcionário
        else
          format.html { render plain: "<p class='text-danger'>Funcionário não encontrado.</p>", status: :not_found }
        end
      end
    end
    
    def search_employee_by_phone(query)
      # Verifica se a query parece um número de telefone (com ou sem parênteses, espaços e hífens)
      if query.match?(/\A(\(?\d{2}\)?[\s\-]?\d{4}[\s\-]?\d{4})\z/)  
        # Remove todos os caracteres não numéricos
        normalized_query = query.gsub(/\D/, '')  
        puts "Consulta por telefone (normalizado): #{normalized_query}"
        # Realiza a busca no banco de dados
        Employee.find_by('REPLACE(phone, " ", "") = ?', normalized_query)
      end
    end

    # Método para buscar o funcionário por e-mail
    def search_employee_by_email(query)
      if query.match?(/\A[\w\._%+-]+@[\w.-]+\.[a-zA-Z]{2,}\z/)  # Verifica se a query parece um e-mail
        puts "Consulta por e-mail: #{query}"
        Employee.find_by(email: query)  # Busca no banco de dados
      end
    end
    
    
    private

    def set_delivery
      @delivery = Delivery.find(params[:id])
    end
  
    def delivery_params
      params.require(:delivery).permit(
        :package_description, 
        :deliverer_id, 
        :employee_id, 
        :delivery_date, 
        :locker_code, 
        :full_address, 
        :imageEntregador, 
        :imageInvoice, 
        :imageProduct,
        :serial  # Caso o serial também precise ser permitido
      )
    end
end 