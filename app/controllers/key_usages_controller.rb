class KeyUsagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:entrada, :transactions_by_serial]
  before_action :set_log, only: [:destroy_log]
  before_action :set_transaction, only: [:destroy_transaction]

  # GET /key_usages
  def index
    @logs = Log.order(created_at: :desc)
  end

  # GET /key_usages/entrada
  def entrada
    @logs = filtered_logs

    @latest_logs = @logs.limit(15)
    flash[:notice] = "Você tem novos logs de movimentação!" if @latest_logs.any?

    @logs_with_alert = build_logs_with_alert(@logs)

    respond_to do |format|
      format.html
      format.xlsx { export_logs_to_excel(@logs_with_alert) }
    end
  end

  # GET /key_usages/transactions_by_serial
  def transactions_by_serial
    @transactions = filtered_transactions
    respond_to do |format|
      format.html
      format.xlsx { export_transactions_to_excel(@transactions) }
    end
  end

  # DELETE /key_usages/:id/destroy_log
  def destroy_log
    if @log.destroy
      flash[:notice] = "Log deletado com sucesso."
    else
      flash[:alert] = "Erro ao deletar log."
    end
    redirect_back fallback_location: entrada_key_usages_path
  end

  # DELETE /key_usages/:id/destroy_transaction
  def destroy_transaction
    @transaction = KeylockerTransaction.find(params[:id])

    if @transaction.destroy
      flash[:notice] = "Transação deletada com sucesso."
    else
      flash[:alert] = "Erro ao deletar transação."
    end

    redirect_back fallback_location: key_usages_transactions_by_serial_path
  end

  private

  # --- Helpers Logs ---
  def filtered_logs
    logs = Log.joins(:employee).where(employees: { user_id: current_user.id }).order(timestamp: :desc)

    if params[:employee_name].present?
      logs = logs.where("employees.name ILIKE ? OR employees.lastname ILIKE ?", "%#{params[:employee_name]}%", "%#{params[:employee_name]}%")
    end

    if params[:start_date].present? && params[:end_date].present?
      logs = logs.where(timestamp: params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    elsif params[:start_date].present?
      logs = logs.where("timestamp >= ?", params[:start_date].to_date.beginning_of_day)
    elsif params[:end_date].present?
      logs = logs.where("timestamp <= ?", params[:end_date].to_date.end_of_day)
    end

    if params[:log_action].present?
      logs = logs.where(action: params[:log_action])
    end

    logs.paginate(page: params[:page], per_page: 20)
  end

  def build_logs_with_alert(logs)
    logs.map do |log|
      log_alert = false
      object_name = log.locker_object || "N/A"

      if log.action == 'retirada' && log.key_id.present?
        last_return_log = Log.where(key_id: log.key_id, action: 'devolução')
                             .where(timestamp: log.timestamp..(log.timestamp + 24.hours))
                             .order(:timestamp).last
        log_alert = last_return_log.nil?
      elsif log.action == 'devolução' && log.key_id.present?
        last_retirada = Log.where(key_id: log.key_id, action: 'retirada')
                           .where("timestamp <= ?", log.timestamp)
                           .order(timestamp: :desc)
                           .first
        object_name = last_retirada&.locker_object || log.locker_object
      end

      if params[:status] == "alert" && !log_alert
        next
      elsif params[:status] == "ok" && log_alert
        next
      end

      { log: log, alert: log_alert, object_name: object_name }
    end.compact
  end

  def export_logs_to_excel(logs)
    response.headers['Content-Disposition'] = "attachment; filename=logs_#{Time.now.strftime('%Y%m%d%H%M')}.xlsx"
    xlsx_package = Axlsx::Package.new
    wb = xlsx_package.workbook

    wb.add_worksheet(name: "Logs") do |sheet|
      sheet.add_row ["Colaborador", "Data/Hora", "Ação", "Objeto", "Locker", "Serial", "Comentários", "Alerta"]
      logs.each do |info|
        log = info[:log]
        alert_text = log.action == 'retirada' && info[:alert] ? "ALERTA" : log.action.capitalize
        sheet.add_row [
          "#{log.employee.name} #{log.employee.lastname}",
          log.timestamp.strftime("%d/%m/%Y %H:%M:%S"),
          log.action.capitalize,
          info[:object_name],
          log.locker_name,
          log.locker_serial,
          log.comments,
          alert_text
        ]
      end
    end

    send_data xlsx_package.to_stream.read, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  # --- Helpers Transactions ---
  def filtered_transactions
    return KeylockerTransaction.none.paginate(page: params[:page], per_page: 20) unless @employee

    keylockers = @employee.keylockers
    return KeylockerTransaction.none.paginate(page: params[:page], per_page: 20) if keylockers.empty?

    transactions = KeylockerTransaction.joins(:keylockerinfo, :giver, :receiver, :keylocker)
                                      .where(keylocker_id: keylockers.pluck(:id))

    transactions = transactions.where('keylockerinfos."tagRFID" ILIKE ?', "%#{params[:tagRFID]}%") if params[:tagRFID].present?
    transactions = transactions.where("employees.name ILIKE :q OR employees.email ILIKE :q", q: "%#{params[:giver]}%").references(:giver) if params[:giver].present?
    transactions = transactions.where("receivers_keylockers.name ILIKE :q OR receivers_keylockers.email ILIKE :q", q: "%#{params[:receiver]}%").references(:receiver) if params[:receiver].present?

    if params[:date].present?
      date = Date.parse(params[:date]) rescue nil
      transactions = transactions.where(delivered_at: date.beginning_of_day..date.end_of_day) if date
    end

    if params[:status].present?
      case params[:status]
      when "disponivel"
        transactions = transactions.where(keylockerinfos: { empty: 1 })
      when "em_uso"
        transactions = transactions.where(keylockerinfos: { empty: 0 })
      end
    end

    transactions.order(created_at: :desc).paginate(page: params[:page], per_page: 20)
  end

  def export_transactions_to_excel(transactions)
    response.headers['Content-Disposition'] = "attachment; filename=transacoes_#{Time.now.strftime('%Y%m%d%H%M')}.xlsx"
    xlsx_package = Axlsx::Package.new
    wb = xlsx_package.workbook

    wb.add_worksheet(name: "Transações") do |sheet|
      sheet.add_row ["Objeto", "Posição", "Serial Locker", "Tag RFID", "Movimentação", "Entregue por", "Para", "Data/Hora", "Status"]

      transactions.each do |t|
        action_text = t.keylockerinfo&.empty == 1 ? "Devolvido" : "Entregue"
        badge_class = t.keylockerinfo&.empty == 1 ? "Disponível" : "Em Uso"
        movement_description = "#{action_text} por #{t.giver&.name || 'N/A'} #{t.giver&.lastname || ''} para #{t.receiver&.name || 'N/A'} #{t.receiver&.lastname || ''}"

        sheet.add_row [
          t.keylockerinfo&.object || 'N/A',
          t.keylockerinfo&.posicion || 'N/A',
          t.keylocker&.serial || 'N/A',
          t.keylockerinfo&.tagRFID&.slice(0,6) || 'N/A',
          movement_description,
          "#{t.giver&.name} #{t.giver&.lastname} (#{t.giver&.email})",
          "#{t.receiver&.name} #{t.receiver&.lastname} (#{t.receiver&.email})",
          t.delivered_at&.strftime("%d/%m/%Y %H:%M") || 'N/A',
          badge_class
        ]
      end
    end

    send_data xlsx_package.to_stream.read, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  # --- Callbacks ---
  def set_employee
    @employee = Employee.find_by(user_id: current_user.id)
  end

  def set_log
    @log = Log.find(params[:id])
  end

  def set_transaction
    @transaction = KeylockerTransaction.find(params[:id])
  end
end
