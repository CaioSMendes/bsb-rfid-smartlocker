class Log < ApplicationRecord
  belongs_to :employee
  # Para registrar o tipo de ação (entrada ou saída)
  validates :action, inclusion: { in: ['retirada', 'devolução'] }
end
