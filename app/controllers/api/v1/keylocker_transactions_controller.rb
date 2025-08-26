class Api::V1::KeylockerTransactionsController < ApplicationController
    # Ignora CSRF apenas para esses métodos
  skip_before_action :verify_authenticity_token, only: [:create, :show, :add_object]

  # Ignora autenticação apenas para esses métodos (teste)
  skip_before_action :authenticate_user!, only: [:create, :show, :add_object]

  # POST /api/v1/keylocker_transactions
  # app/controllers/api/v1/keylocker_transactions_controller.rb
  def create
    puts "➡️ Params recebidos: #{params.inspect}"

    # 1️⃣ Busca os registros
    keylocker = Keylocker.find_by(serial: params[:locker_serial])
    puts "🔹 Keylocker encontrado: #{keylocker.inspect}"

    keylocker_info = Keylockerinfo.find_by(tagRFID: params[:tagRFID])
    puts "🔹 KeylockerInfo encontrado: #{keylocker_info.inspect}"

    giver = Employee.find(params[:giver_id])
    puts "🔹 Giver encontrado: #{giver.inspect}"

    receiver = Employee.find(params[:receiver_id])
    puts "🔹 Receiver encontrado: #{receiver.inspect}"

    action_type = params[:action_type]
    puts "🔹 Action type: #{action_type}"

    # 2️⃣ Validação
    if keylocker_info.nil?
      puts "❌ Objeto não encontrado"
      render json: { status: "ERROR", message: "Objeto não encontrado" }, status: :not_found
      return
    end

    unless %w[entregar devolver].include?(action_type)
      puts "❌ Ação inválida"
      render json: { status: "ERROR", message: "Ação inválida" }, status: :unprocessable_entity
      return
    end

    # 3️⃣ Cria a transação no KeylockerTransaction
    transaction = KeylockerTransaction.create!(
      keylockerinfo: keylocker_info,
      giver: giver,
      receiver: receiver,
      keylocker: keylocker,
      delivered_at: Time.current
    )
    puts "✅ Transação criada: #{transaction.inspect}"

    # 4️⃣ Prepara os dados para logs
    changes = []
    locker_object = keylocker_info.object
    status, action, comments = "", "", ""
    employee = giver

    case action_type
    when 'entregar'
      keylocker_info.update(empty: 0)
      status = "Entregue"
      action = "entrega"
      comments = "Objeto #{locker_object} entregue por #{giver.email} para #{receiver.email}"
    when 'devolver'
      keylocker_info.update(empty: 1)
      status = "Disponível"
      action = "devolução"
      comments = "Objeto #{locker_object} devolvido por #{receiver.email} para #{giver.email}"
      employee = receiver
    end
    puts "🔹 Status após atualização: #{status}, ação: #{action}, comments: #{comments}"

    # 5️⃣ Adiciona no array de mudanças
    changes << {
      employee_id: employee.id,
      action: action,
      tagrfid: keylocker_info.tagRFID, # <-- Aqui
      keylocker_id: keylocker.id,
      locker_serial: keylocker.serial,
      locker_object: locker_object,
      locker_name: keylocker.nameDevice,
      timestamp: Time.current,
      status: status,
      comments: comments
    }
    puts "🔹 Array de mudanças: #{changes.inspect}"

    # 6️⃣ Salva todos os logs de uma vez
    Logsmovimetation.insert_all(changes) unless changes.empty?
    puts "✅ Logs inseridos com sucesso"

    # 7️⃣ Retorna a resposta
    render json: {
      status: "SUCCESS",
      message: "Transação registrada",
      data: {
        object: locker_object,
        tagRFID: keylocker_info.tagRFID,
        locker_serial: keylocker&.serial,
        delivered_at: transaction.delivered_at,
        action: action_type,
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
