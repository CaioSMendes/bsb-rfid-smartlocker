class Item < ApplicationRecord
  belongs_to :asset_management
  belongs_to :category, optional: true  # se quiser permitir nulo em algumas situações
  belongs_to :location
  has_one_attached :image
  has_many :historic_managements, dependent: :destroy

  validates :tagRFID, presence: true, uniqueness: true
  validates :category, presence: true  # garante que sempre tenha uma categoria
  
  attr_accessor :category_name, :location_name

  before_validation :assign_category_and_location

  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  def log_create
    HistoricManagement.create(
      item: self,
      user: Current.user, # você precisa definir Current.user ou passar o user no controller
      action: "create",
      description: "Item criado",
      action_time: Time.current
    )
  end

  def log_update
    HistoricManagement.create(
      item: self,
      user: Current.user,
      action: "update",
      description: "Item atualizado",
      action_time: Time.current
    )
  end

  def log_destroy
    HistoricManagement.create(
      item: self,
      user: Current.user,
      action: "destroy",
      description: "Item removido",
      action_time: Time.current
    )
  end

  private

   def assign_category_and_location
    # Categoria
    if category_name.present? && category_id.blank?
      cat = asset_management.categories.find_or_create_by(name: category_name)
      self.category = cat
    end

    # Localização
    if location_name.present? && location_id.blank?
      loc = asset_management.locations.find_or_create_by(name: location_name)
      self.location = loc
    end
  end
end
