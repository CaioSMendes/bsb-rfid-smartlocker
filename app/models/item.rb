class Item < ApplicationRecord
  belongs_to :asset_management
  belongs_to :category
  belongs_to :location
  has_one_attached :image


  validates :tagRFID, presence: true, uniqueness: true

  validate :category_and_location_belong_to_same_asset_management

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
