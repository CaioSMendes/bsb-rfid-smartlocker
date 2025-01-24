# app/controllers/users/sessions_controller.rb
module Users
    class SessionsController < Devise::SessionsController
      # Pule a verificação do CSRF para ações específicas
      skip_before_action :verify_authenticity_token, only: [:create]
  
      # Métodos padrão do Devise, se você precisar personalizar
      def new
        super
      end
  
      def create
        super
      end
  
      def destroy
        super
      end
    end
  end
  