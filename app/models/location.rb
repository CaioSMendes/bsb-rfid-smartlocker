class Location < ApplicationRecord
  belongs_to :asset_management
  has_many :items, dependent: :destroy
  belongs_to :user   # cada localização pertence a um usuário

  validates :name, presence: true

  after_create :set_code
  after_create :replicate_to_user_deposits
  after_update :update_in_other_deposits
  after_destroy :destroy_in_other_deposits

  private

  # Define o código como o ID se estiver vazio
  def set_code
    update_column(:code, id) if code.blank?
  end

  # Criar location nos outros depósitos do mesmo usuário
  def replicate_to_user_deposits
    return unless user.present?

    user_deposits = user.asset_managements.where.not(id: asset_management_id)
    return if user_deposits.empty?

    locations_to_create = user_deposits.map do |deposit|
      {
        name: name,
        description: description,
        address: address,
        code: code,
        asset_management_id: deposit.id,
        user_id: user.id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Location.insert_all(locations_to_create)
  end

  # Atualizar location nos outros depósitos do mesmo usuário
  def update_in_other_deposits
    Location.where(name: name, user_id: user_id)
            .where.not(asset_management_id: asset_management_id)
            .update_all(
              description: description,
              address: address,
              updated_at: Time.current
            )
  end

  # Remover location nos outros depósitos do mesmo usuário
  def destroy_in_other_deposits
    Location.where(name: name, user_id: user_id)
            .where.not(asset_management_id: asset_management_id)
            .delete_all
  end
end