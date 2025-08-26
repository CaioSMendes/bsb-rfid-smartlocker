class Logsmovimetation < ApplicationRecord
  belongs_to :employee
  belongs_to :keylocker
  # Para registrar o tipo de ação (entrada ou saída)
  validates :action, inclusion: { in: ['retirada', 'devolução'] }
end
