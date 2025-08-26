class Keylockerinfo < ApplicationRecord
  belongs_to :keylocker
  has_one_attached :image

  # Define empty = 1 somente na criação do registro
  before_validation :set_empty_default, on: :create

  def set_empty_default
    self.empty ||= 1
  end

  # Método para alterar o status de 'empty'
  def mark_as_full
    update(empty: 1)
  end

  def mark_as_empty
    update(empty: 0)
  end
end
