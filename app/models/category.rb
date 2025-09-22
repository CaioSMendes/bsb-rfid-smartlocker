class Category < ApplicationRecord
  belongs_to :asset_management
  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true

  after_create :replicate_to_user_deposits
  after_update :update_in_other_deposits
  after_destroy :destroy_in_other_deposits

  private

  # Replicar categoria para todos os depósitos do mesmo usuário
  def replicate_to_user_deposits
    return unless user.present?

    # Todos os depósitos do usuário, exceto o atual
    user_deposits = user.asset_managements.where.not(id: asset_management_id)
    return if user_deposits.empty?

    categories_to_create = user_deposits.map do |deposit|
      {
        name: name,
        description: description,
        asset_management_id: deposit.id,
        user_id: user.id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Category.insert_all(categories_to_create) if categories_to_create.any?
  end

  # Atualizar categoria nos outros depósitos do mesmo usuário
  def update_in_other_deposits
    Category.where(name: name_was, user_id: user_id)
            .where.not(asset_management_id: asset_management_id)
            .update_all(
              name: name,
              description: description,
              updated_at: Time.current
            )
  end

  # Apagar categoria nos outros depósitos do mesmo usuário
  def destroy_in_other_deposits
    Category.where(name: name, user_id: user_id)
            .where.not(asset_management_id: asset_management_id)
            .delete_all
  end
end