class Employee < ApplicationRecord
  before_create :set_default_status
  before_save :normalize_phone
  has_many :workdays, dependent: :destroy
  belongs_to :user
  has_and_belongs_to_many :keylockers
  has_one_attached :profile_picture
  has_many :logs

  accepts_nested_attributes_for :workdays, reject_if: :all_blank, allow_destroy: true
  
  validate :at_least_one_keylocker

  def formatted_phone
    formatted = phone.gsub(/\D/, '') # Remove todos os caracteres não numéricos
    if formatted.length == 11
      formatted = formatted.insert(0, '(') # Adiciona parênteses no DDD
      formatted = formatted.insert(3, ') ') # Adiciona espaço após o DDD
      formatted = formatted.insert(9, '-')  # Adiciona hífen entre os números
    end
    formatted
  end

  private

  def at_least_one_keylocker
    errors.add(:base, 'Deve haver pelo menos um locker atribuído') if keylockers.none?
  end

  def normalize_phone
    if phone.present?
      self.phone = phone.gsub(/\D/, '')
    end
  end

  def set_default_status
    self.status ||= 'debloqueado'
  end
end