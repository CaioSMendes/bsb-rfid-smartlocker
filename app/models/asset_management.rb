class AssetManagement < ApplicationRecord
    has_many :locations, dependent: :destroy
    has_many :categories, dependent: :destroy
    has_many :items, dependent: :destroy
    before_create :generate_serial

    validates :name, presence: true

    private

    def generate_serial
        self.serial ||= SecureRandom.alphanumeric(10).upcase
    end
end
