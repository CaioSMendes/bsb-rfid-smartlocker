class Item < ApplicationRecord
  belongs_to :asset_management
  belongs_to :category
  belongs_to :location
  has_one_attached :image
  has_many :historic_managements, dependent: :destroy

  validates :tagRFID, presence: true, uniqueness: true
  validate :category_and_location_belong_to_same_asset_management

  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  def log_create
    HistoricManagement.create(
      item: self,
      user: Current.user, # você precisa definir Current.user ou passar o user no controller
      action: "create",
      description: "Item criado",
      action_time: Time.current
    )
  end

  def log_update
    HistoricManagement.create(
      item: self,
      user: Current.user,
      action: "update",
      description: "Item atualizado",
      action_time: Time.current
    )
  end

  def log_destroy
    HistoricManagement.create(
      item: self,
      user: Current.user,
      action: "destroy",
      description: "Item removido",
      action_time: Time.current
    )
  end

  private

  def category_and_location_belong_to_same_asset_management
    if category && category.asset_management_id != asset_management_id
      errors.add(:category_id, "must belong to the same Asset Management")
    end
    if location && location.asset_management_id != asset_management_id
      errors.add(:location_id, "must belong to the same Asset Management")
    end
  end
end
