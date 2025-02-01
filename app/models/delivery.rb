class Delivery < ApplicationRecord
    belongs_to :deliverer
    belongs_to :employee
    has_one_attached :image
end