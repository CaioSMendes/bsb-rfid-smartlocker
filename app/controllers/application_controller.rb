class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :check_finance_status
    before_action :configure_permitted_parameters, if: :devise_controller?
    layout :layout_by_user_role
    before_action :carregar_notificacoes
    helper_method :contador_notificacoes
    before_action :set_current_user

    def contador_notificacoes
      return 0 unless user_signed_in? # Garante que só conta se o usuário estiver logado
  
      # Conta as notificações novas do usuário
      Log.joins(:employee)
         .where(employees: { user_id: current_user.id })
         .where("logs.created_at > ?", 5.minutes.ago) # Exemplo: últimas 5 min
         .count
    end

    private
    
    def set_current_user
      # Ajuste conforme sua autenticação
      Current.user = current_user # current_user do Devise ou outro método
    end

    def layout_by_user_role
      if user_signed_in?
        if current_user.admin?
          'admin' # Layout para administradores
        else
          'user' # Layout para usuários logados (não administradores)
        end
      else
        'devise' # Terceira opção para usuários não logados
      end
    end

    def carregar_notificacoes
      return unless user_signed_in?
  
      last_seen_id = params[:last_seen_id].to_i
  
      # Busca SOMENTE notificações novas, respeitando o limite de 10
      @logs = Log.joins(:employee)
                 .where(employees: { user_id: current_user.id })
                 .where("logs.id > ?", last_seen_id)
                 .order(created_at: :desc)
                 .limit(40) # Mantém no máximo 10 notificações exibidas
  
      # Cria mensagens formatadas
      @notifications = @logs.map do |log|
        action_icon = log.action == "devolução" ? "<i class='fa fa-arrow-down text-success'></i>" : "<i class='fa fa-arrow-up text-danger'></i>"
        message = "Objeto #{log.action == 'devolução' ? 'entregue' : 'retirado'} #{action_icon} por #{log.employee.name} em #{log.created_at.strftime('%d/%m/%Y %H:%M')}"
        { id: log.id, icon: action_icon, message: message }
      end
  
      # Retorna as novas notificações e o último ID
      #render json: { notifications: @notifications, last_id: @logs.maximum(:id) }
    end
    
    
    def check_finance_status
        if user_signed_in? && current_user.finance == 'inadimplente' && !on_inadimplente_page?
          flash[:alert] = 'Você está inadimplente. Entre em contato para regularizar sua situação.'
          redirect_to inadimplente_path
        elsif user_signed_in? && current_user.finance != 'inadimplente' && on_inadimplente_page?
          flash[:alert] = 'Você não tem permissão para acessar essa página.'
          redirect_to root_path
        end
      end
    
      def on_inadimplente_page?
        request.path.eql?(inadimplente_path)
      end

    protected
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(
            :sign_up, keys: [
            :phone, :name, :lastname, :cnpj, :nameCompany, :street, :city, :state, :zip_code, :neighborhood, :finance, :complement
        ])
        devise_parameter_sanitizer.permit(
            :account_update, keys: [
                :phone, :name, :lastname, :cnpj, :nameCompany, :street, :city, :state, :zip_code, :neighborhood, :finance, :complement
            ]
        )
      end
end

 


 
