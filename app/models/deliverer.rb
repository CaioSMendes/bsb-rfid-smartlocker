class Deliverer < ApplicationRecord
    belongs_to :keylocker
    has_many :deliveries
  
    validates :email, :phone, :cpf, presence: true
    validates :cpf, uniqueness: true
end