class Deliverer < ApplicationRecord
    belongs_to :keylocker, optional: true  # Torna a associação opcional
    has_many :deliveries
    before_save :normalize_phone

    validates :email, :phone, :cpf, presence: true
    validates :cpf, uniqueness: { message: "Já existe um entregador com esse CPF" }


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

    def normalize_phone
        if phone.present?
          self.phone = phone.gsub(/\D/, '')
        end
    end
end