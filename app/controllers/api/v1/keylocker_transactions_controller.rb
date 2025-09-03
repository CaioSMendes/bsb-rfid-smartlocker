class Api::V1::KeylockerTransactionsController < ApplicationController
    # Ignora CSRF apenas para esses métodos
  skip_before_action :verify_authenticity_token, only: [:create, :show, :add_object]

  # Ignora autenticação apenas para esses métodos (teste)
  skip_before_action :authenticate_user!, only: [:create, :show, :add_object]

  # POST /api/v1/keylocker_transactions
  # app/controllers/api/v1/keylocker_transactions_controller.rb
def create
  keylocker = Keylocker.find_by(serial: params[:locker_serial])
  keylocker_info = Keylockerinfo.find_by(tagRFID: params[:tagRFID])
  giver = Employee.find_by(id: params[:giver_id])
  receiver = Employee.find_by(id: params[:receiver_id])
  action_type = params[:action_type]

  # Validações básicas
  if keylocker_info.nil?
    render json: { status: "ERROR", message: "Objeto não encontrado" }, status: :not_found and return
  end

  unless %w[entregar devolver].include?(action_type)
    render json: { status: "ERROR", message: "Ação inválida" }, status: :unprocessable_entity and return
  end

  # Validação do estado do objeto
  if action_type == 'entregar' && keylocker_info.empty == 0
    render json: { status: "ERROR", message: "Objeto já está em uso, não pode ser retirado" }, status: :forbidden and return
  elsif action_type == 'devolver' && keylocker_info.empty == 1
    render json: { status: "ERROR", message: "Objeto já está disponível, não pode ser devolvido" }, status: :forbidden and return
  end

  # Verifica se quem está devolvendo realmente retirou o objeto
  ultima_transacao = KeylockerTransaction.where(keylocker_info_id: keylocker_info.id)
                                        .order(created_at: :desc)
                                        .first
  if action_type == 'devolver'
    if ultima_transacao.nil? || ultima_transacao.receiver_employee_id != giver.id
      render json: { status: "ERROR", message: "Somente quem retirou pode devolver" }, status: :forbidden and return
    end
  end

  # Define status da transação e estado do objeto
  status = action_type == 'entregar' ? "Entregue" : "Devolvido"
  empty_value = action_type == 'devolver' ? 1 : 0
  available_status = empty_value == 1 ? "Disponível" : "Em Uso"

  # Cria a descrição completa da ação
  movement_description = "#{status} por #{giver&.name || 'N/A'} #{giver&.lastname || ''} para #{receiver&.name || 'N/A'} #{receiver&.lastname || ''}"

  # Cria a transação
  transaction = KeylockerTransaction.create!(
    keylockerinfo: keylocker_info,
    giver: giver,
    receiver: receiver,
    keylocker: keylocker,
    delivered_at: Time.current,
    status: status,
    movement_description: movement_description
  )

  # Atualiza o estado atual do objeto
  keylocker_info.update(empty: empty_value)

  # Retorna JSON com os dados da transação
  render json: {
    status: "SUCCESS",
    message: "Transação registrada",
    data: {
      object: keylocker_info.object,
      tagRFID: keylocker_info.tagRFID,
      locker_serial: keylocker.serial,
      delivered_at: transaction.delivered_at,
      status: status,
      action: action_type,
      available: available_status,
      movement_description: movement_description,
      from: { id: giver.id, name: giver.name, lastname: giver.lastname },
      to: { id: receiver.id, name: receiver.name, lastname: receiver.lastname }
    }
  }, status: :ok
end



def add_object
  keylocker = Keylocker.find_by(serial: params[:locker_serial])
  return render json: { error: "Locker não encontrado" }, status: :not_found unless keylocker

  if keylocker.keylockerinfos.count >= keylocker.qtd
    return render json: { error: "Locker cheio" }, status: :unprocessable_entity
  end

  next_position = (keylocker.keylockerinfos.maximum(:posicion) || 0) + 1
  info_params = params.require(:keylockerinfo).permit(:object, :tagRFID, :idInterno, :description)

  new_slot = keylocker.keylockerinfos.build(info_params.merge(posicion: next_position, empty: 1))

  if new_slot.save
    # 🔹 Render apenas os campos essenciais
    render json: { 
      message: "Objeto adicionado com sucesso",
      keylockerinfo: {
        id: new_slot.id,
        object: new_slot.object,
        posicion: new_slot.posicion,
        tagRFID: new_slot.tagRFID,
        idInterno: new_slot.idInterno,
        description: new_slot.description,
        empty: new_slot.empty
      }
    }, status: :created
  else
    render json: { error: new_slot.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end
end

  # GET /api/v1/keylocker_transactions/:tagRFID
  def show
    keylocker_info = KeylockerInfo.find_by(tagRFID: params[:tagRFID])

    if keylocker_info.nil?
      render json: { status: "ERROR", message: "Objeto não encontrado" }, status: :not_found
      return
    end

    transactions = KeylockerTransaction.where(keylocker_info: keylocker_info)

    render json: {
      status: "SUCCESS",
      message: "Histórico de transações do objeto #{params[:tagRFID]}",
      data: transactions.map do |t|
        {
          object: t.keylocker_info.object,
          tagRFID: t.keylocker_info.tagRFID,
          locker_serial: t.keylocker&.serial,
          delivered_at: t.delivered_at,
          from: { id: t.giver.id, name: t.giver.name, lastname: t.giver.lastname },
          to: { id: t.receiver.id, name: t.receiver.name, lastname: t.receiver.lastname }
        }
      end
    }, status: :ok
  end
end
