class KeyUsagesController < ApplicationController
  before_action :authenticate_user!
  def index
    # Buscar todos os logs e ordenar por data
    @logs = Log.order(created_at: :desc)

    # Filtrar por um usuário específico, caso necessário
    # @logs = Log.where(employee_id: current_user.employee.id).order(created_at: :desc)
  end

  def entrada
    # Pegando os logs relacionados aos employees do current_user com paginação
    @logs = Log.joins(:employee)
               .where(employees: { user_id: current_user.id })
               .order(created_at: :desc)
               .paginate(page: params[:page], per_page: 20)
  
    # Exibindo no console os logs recuperados para depuração
    puts "Logs encontrados para o usuário #{current_user.email}:"

     # Verificando se há movimentação de log
     @latest_logs = @logs.limit(5)

    if @latest_logs.any?
      # Exemplo de notificação
      flash[:notice] = "Você tem novos logs de movimentação!"
    end
  
    # Criando um array de logs com alertas
    @logs_with_alert = @logs.map do |log|
      # Verifica se não há uma devolução associada à retirada após 24 horas
      last_return_log = Log.where(key_id: log.key_id, action: 'devolução')
                           .where("timestamp > ?", log.timestamp + 24.hours)
                           .order(:timestamp).last
  
      # Se não existir log de devolução após 24 horas, marque um alerta
      log_alert = last_return_log.nil?
  
      # Atribuindo o log e o alerta a um hash para uso na view
      { log: log, alert: log_alert }
    end
  end  

  def transactions
    # Aqui você pode buscar apenas logs de transações
    @transactions = KeylockerTransaction.includes(:giver, :receiver, :keylocker, :keylockerinfo)
                                        .order(delivered_at: :desc)
                                        .paginate(page: params[:page], per_page: 20)
  end
end
  