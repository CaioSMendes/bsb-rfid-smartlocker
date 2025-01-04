class Delivery < ApplicationRecord
    belongs_to :deliverer
    belongs_to :employee
end