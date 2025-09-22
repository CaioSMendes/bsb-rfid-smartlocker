class AssetManagement < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  belongs_to :user  # cada depósito pertence a um usuário
  before_create :generate_serial

  after_create :copy_existing_categories
  after_create :copy_existing_locations

  validates :name, presence: true

  private

  # Quando criar um novo depósito, clona as categorias do mesmo usuário
  def copy_existing_categories
    return unless user.present?

    existing_categories = Category.where(user_id: user.id)
                                  .where.not(asset_management_id: id)
                                  .distinct.pluck(:name, :description)

    categories_to_create = existing_categories.map do |name, description|
      { name: name, description: description, asset_management_id: id, user_id: user.id, created_at: Time.current, updated_at: Time.current }
    end

    Category.insert_all(categories_to_create) if categories_to_create.any?
  end

  # Quando criar um novo depósito, clona as locations do mesmo usuário
  def copy_existing_locations
    return unless user.present?

    existing_locations = Location.where(user_id: user.id)
                                 .where.not(asset_management_id: id)
                                 .distinct.pluck(:name, :address, :description)

    locations_to_create = existing_locations.map do |name, address, description|
      { name: name, address: address, description: description, asset_management_id: id, user_id: user.id, created_at: Time.current, updated_at: Time.current }
    end

    Location.insert_all(locations_to_create) if locations_to_create.any?
  end

  def generate_serial
    self.serial ||= SecureRandom.alphanumeric(10).upcase
  end
end