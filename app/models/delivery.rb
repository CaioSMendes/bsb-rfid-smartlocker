class Delivery < ApplicationRecord
    belongs_to :deliverer
    belongs_to :employee
    has_one_attached :imageEntregador
    has_one_attached :imageInvoice
    has_one_attached :imageProduct

    validates :package_description, :full_address, :deliverer_id, :employee_id, presence: true
end