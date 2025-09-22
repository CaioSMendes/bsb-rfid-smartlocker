class Category < ApplicationRecord
  belongs_to :asset_management
  has_many :items, dependent: :destroy

  validates :name, presence: true
end
