class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :check_finance_status
    before_action :configure_permitted_parameters, if: :devise_controller?
    layout :layout_by_user_role

    private
    
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

 


 
