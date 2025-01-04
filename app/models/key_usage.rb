class KeyUsage < ApplicationRecord
    belongs_to :employee
    belongs_to :keylocker

    scope :in_use, -> { where(status: 'Pegou') }
    scope :available, -> { where(status: 'Devolveu') }
end
