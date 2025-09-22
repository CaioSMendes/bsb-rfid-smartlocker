class Location < ApplicationRecord
  belongs_to :asset_management
  has_many :items, dependent: :destroy

  after_create :set_code

  validates :name, presence: true

  private

  def set_code
    update_column(:code, id) if code.blank?
  end
end
