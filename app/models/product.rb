class Product < ApplicationRecord
    has_one_attached :image_entregador
    has_one_attached :image_invoice
    has_one_attached :image_product
end
