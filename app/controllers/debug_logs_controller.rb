class DebugLogsController < ApplicationController
  skip_before_action :authenticate_user!


  def show_logs
    # Dados de debug
    @debug_data = {
      ip_address: request.remote_ip,
      host: request.host,
      user_agent: request.user_agent,
      session_data: session.to_hash,
      params: params.to_unsafe_h,
      devise_trace: devise_debug_trace,
      logs: retrieve_logs,
      operation_status: fetch_operation_status, # Adicionado
      operation_message: fetch_operation_message # Adicionado
    }
  end

  private

  def devise_debug_trace
    Devise.mappings.keys.map do |scope|
      {
        scope: scope,
        warden_data: warden.raw_session["warden.user.#{scope}.key"]
      }
    end
  end

  def retrieve_logs
    log_file = Rails.root.join('log', "#{Rails.env}.log")
    if File.exist?(log_file)
      File.readlines(log_file).last(100)
    else
      ["Log file not found"]
    end
  end

  def fetch_operation_status
    # Exemplo de lógica para determinar o status
    if session[:user_id]
      "Sucesso"
    else
      "Erro"
    end
  end

  def fetch_operation_message
    # Exemplo de mensagem detalhada
    if session[:user_id]
      "Usuário autenticado com sucesso."
    else
      "Falha na autenticação. Verifique as credenciais."
    end
  end
end
