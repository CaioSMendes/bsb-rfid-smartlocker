class Keylocker < ApplicationRecord
  validates_uniqueness_of :owner, scope: [:nameDevice, :serial, :status]
  validates :owner, uniqueness: { scope: [:nameDevice, :serial, :status] }
  has_many :key_usages
  validates :door, inclusion: { in: ["aberto", "fechado"] }
  has_many :user_lockers
  has_many :users, through: :user_lockers
  has_many :keylockerinfos, dependent: :destroy
  has_many :deliverers
  has_many :logs
  has_many :logsmovimetations

  accepts_nested_attributes_for :keylockerinfos, allow_destroy: true

  has_many :employees_keylockers
  has_and_belongs_to_many :employees
  
  before_create :generate_serial
  before_validation :set_default_status, on: :create
  before_validation :set_default_qtd_digito, on: :create  # ✅ Aqui

  validates :qtdDigito, numericality: { greater_than_or_equal_to: 6, only_integer: true, message: "deve ser igual ou maior do que 6" }

  def toggle_and_save_status!
    # Implemente a lógica para alternar e salvar o status no banco de dados
    self.status = (status == 'bloqueado' ? 'desbloqueado' : 'bloqueado')
    save!
  end

  private

  def generate_serial
    self.serial ||= SecureRandom.alphanumeric(10).upcase
  end

  def set_default_status
    self.status ||= "desbloqueado"
  end

   def set_default_qtd_digito
    self.qtdDigito ||= 6
  end
end
