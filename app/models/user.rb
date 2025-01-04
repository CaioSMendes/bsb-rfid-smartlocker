class User < ApplicationRecord
  before_create :set_default_role
  before_create :set_default_finance
  enum role: { admin: 'admin', user: 'user'}

  has_many :user_lockers
  has_many :keylockers, through: :user_lockers
  has_one :employee #funciona

  has_one :keylocker  # Adicione esta linha
  has_one :address


  #accepts_nested_attributes_for :employees

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_save :ensure_authentication_token

  # Método para atribuir um locker a um usuário
  def assign_keylocker(keylocker)
    self.keylockers << keylocker unless self.keylockers.include?(keylocker)
  end

  # Método para remover um locker de um usuário
  def remove_keylocker(keylocker)
    self.keylockers.delete(keylocker)
  end


  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  private

  def set_default_role
    self.role ||= 'user'
  end

  def set_default_finance
    self.finance ||= 'adimplente'
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end  
end
