class HistoricManagement < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validates :action, presence: true
  validates :action_time, presence: true
end
