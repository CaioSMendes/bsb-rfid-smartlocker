module Api
  module V1
    class AssetManagementsController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!  # não usamos Devise aqui

      # POST /api/v1/asset_managements/list
      # Body JSON: { "email": "...", "password": "..." }
      def list
        user = authenticate_user
        return unless user

        asset_managements = user.asset_managements.includes(items: [:category, :location])

        render json: asset_managements.map { |am|
          {
            id: am.id,
            name: am.name,
            description: am.description,
            items: am.items.map { |item| item_json(item) }
          }
        }
      end

      def lookup_item
        user = authenticate_user
        return unless user

        item = Item.joins(:asset_management)
                   .where(tagRFID: params[:tagRFID], asset_managements: { user_id: user.id })
                   .first

        if item
          render json: item_json(item)
        else
          render json: { error: "Item não encontrado" }, status: :not_found
        end
      end

    # POST /api/v1/items/transfer
# Body JSON: { "email": "...", "password": "...", "tagRFID": "...", "new_asset_management_id": 2 }
def transfer_item
  # Autentica o usuário via JSON (email + senha)
  user = authenticate_user
  return unless user

  puts "Parâmetros recebidos: #{params.inspect}"

  # Localiza o item pelo tagRFID dentro dos depósitos do usuário
  item = Item.joins(:asset_management)
             .where(tagRFID: params[:tagRFID], asset_managements: { user_id: user.id })
             .first

  unless item
    puts "Item não encontrado"
    return render json: { error: "Item não encontrado" }, status: :not_found
  end
  puts "Item encontrado: #{item.inspect}"

  # Busca o depósito de destino pelo id
  new_deposit = user.asset_managements.find_by(id: params[:new_asset_management_id])
  unless new_deposit
    puts "Depósito de destino inválido"
    return render json: { error: "Depósito de destino inválido" }, status: :unprocessable_entity
  end
  puts "Depósito de destino: #{new_deposit.name}"

  # 🚫 Impede transferir para o mesmo depósito
  if item.asset_management_id == new_deposit.id
    puts "Tentativa de transferir para o mesmo depósito"
    return render json: { error: "Item já está nesse depósito" }, status: :unprocessable_entity
  end

  # Guarda o depósito antigo
  old_deposit_name = item.asset_management.name

  # Atualiza o item para o novo depósito
  if item.update(asset_management: new_deposit)
    puts "Item transferido de #{old_deposit_name} para #{new_deposit.name}"

    # Cria registro no histórico
    HistoricManagement.create(
      item: item,
      user: user,
      action: "Transferência",
      description: "Transferido de #{old_deposit_name} para #{new_deposit.name}",
      action_time: Time.current
    )

    render json: { message: "Item transferido com sucesso", item: item_json(item) }
  else
    puts "Erro ao transferir o item: #{item.errors.full_messages}"
    render json: { error: "Erro ao transferir o item", details: item.errors.full_messages }, status: :unprocessable_entity
  end
end

# POST /items/compare
def compare
  user = authenticate_user
  return unless user

  puts "=== Compare iniciado ==="
  puts "Usuário autenticado: #{user.id} - #{user.email}"

  tag_lidas = Array(params[:tagRfid]) # aceita string ou array
  deposito_id = params[:deposito_id] # agora usa deposito_id enviado no JSON

  puts "Tags lidas recebidas: #{tag_lidas.inspect}"
  puts "Depósito ID recebido: #{deposito_id}"

  # Busca o depósito do usuário
  deposito = user.asset_managements.find_by(id: deposito_id)
  unless deposito
    puts "Depósito inválido!"
    return render json: { error: "Depósito inválido" }, status: :not_found
  end

  puts "Depósito encontrado: #{deposito.name} (ID: #{deposito.id})"

  # Todos os itens cadastrados no depósito
  itens_cadastrados = deposito.items
  puts "Itens cadastrados no depósito: #{itens_cadastrados.pluck(:tagRFID).inspect}"

  # Presentes: tags lidas que pertencem ao depósito
  presentes = itens_cadastrados.where(tagRFID: tag_lidas)
  puts "Presentes: #{presentes.pluck(:tagRFID).inspect}"

  # Faltando: itens cadastrados no depósito mas não foram lidos
  faltando = itens_cadastrados.where.not(tagRFID: tag_lidas)
  puts "Faltando: #{faltando.pluck(:tagRFID).inspect}"

  # Extras: tags lidas que não pertencem a esse depósito, mas existem em outros depósitos
  extras = Item.where(tagRFID: tag_lidas)
               .where.not(asset_management_id: deposito.id)
               .map do |i|
                 { tagRFID: i.tagRFID, deposito_id: i.asset_management_id, status: i.status || "Desconhecido" }
               end
  puts "Extras iniciais: #{extras.inspect}"

  # Adiciona tags lidas que não existem em nenhum lugar
  tag_lidas.each do |tag|
    unless presentes.map(&:tagRFID).include?(tag) || extras.map { |e| e[:tagRFID] }.include?(tag)
      extras << { tagRFID: tag, deposito_id: nil, status: "Desconhecido" }
    end
  end
  puts "Extras finais após inclusão de desconhecidos: #{extras.inspect}"

  # Formata o JSON de saída
  render json: {
    presentes: presentes.map do |i|
      {
        id: i.id,
        name: i.name,
        tagRFID: i.tagRFID,
        idInterno: i.idInterno,
        description: i.description,
        asset_management_id: i.asset_management_id,
        status: i.status,
        vazio: i.empty,
        criado_em: i.created_at.strftime("%d/%m/%Y %H:%M"),
        editado_em: i.updated_at.strftime("%d/%m/%Y %H:%M")
      }
    end,
    faltando: faltando.map do |i|
      {
        id: i.id,
        name: i.name,
        tagRFID: i.tagRFID,
        idInterno: i.idInterno,
        description: i.description,
        asset_management_id: i.asset_management_id,
        status: i.status,
        vazio: i.empty,
        criado_em: i.created_at.strftime("%d/%m/%Y %H:%M"),
        editado_em: i.updated_at.strftime("%d/%m/%Y %H:%M")
      }
    end,
    extras: extras
  }
  puts "=== Compare finalizado ==="
end

      private

      # Autenticação pelo JSON enviado
      def authenticate_user
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
            @current_user = user
        else
            render json: { error: "Credenciais inválidas" }, status: :unauthorized
        end
      end

      # JSON simplificado para cada item
      def item_json(item)
        {
          id: item.id,
          name: item.name,
          tagRFID: item.tagRFID,
          idInterno: item.idInterno,
          descricao: item.description,
          deposito_id: item.asset_management&.id,
          deposito: item.asset_management&.name,
          categoria: item.category&.name || "Sem categoria",
          localizacao: item.location&.name || "Sem localização",
          status: item.status,
          vazio: item.empty,
          criado_em: item.created_at.strftime("%d/%m/%Y %H:%M"),
          editado_em: item.updated_at.strftime("%d/%m/%Y %H:%M")
        }
      end
    end
  end
end