class Keylockerinfo < ApplicationRecord
  belongs_to :keylocker
  has_one_attached :image
  # Exemplo de um callback para definir o status de 'empty' ao criar um registro.
  after_initialize :set_empty_default

  validate :correct_image_type

  def set_empty_default
    self.empty ||= 1  # Define 1 como valor padrão para 'empty' se não for especificado
  end

  # Método para alterar o status de 'empty'
  def mark_as_full
    update(empty: 1)
  end

  def mark_as_empty
    update(empty: 0)
  end

  private

  def correct_image_type
    if image.attached? && !image.content_type.in?(%w(image/jpeg image/png))
      errors.add(:image, 'must be a JPEG, JPG, or PNG')
    end
  end

end
