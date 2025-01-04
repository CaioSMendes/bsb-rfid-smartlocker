class Employee < ApplicationRecord
  before_create :set_default_status
  has_many :workdays, dependent: :destroy
  belongs_to :user
  has_and_belongs_to_many :keylockers
  has_one_attached :profile_picture
  
  accepts_nested_attributes_for :workdays, reject_if: :all_blank, allow_destroy: true
  
  validate :at_least_one_keylocker

  private

  def at_least_one_keylocker
    errors.add(:base, 'Deve haver pelo menos um locker atribuído') if keylockers.none?
  end

  def set_default_status
    self.status ||= 'debloqueado'
  end
end
