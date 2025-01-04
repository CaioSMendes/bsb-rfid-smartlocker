class HistoryEntry < ApplicationRecord
   
    validates :owner, presence: true
    validates :name_device, presence: true

    scope :unread, -> { where(read: false) }
  end