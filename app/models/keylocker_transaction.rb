class KeylockerTransaction < ApplicationRecord
  belongs_to :keylockerinfo, class_name: "Keylockerinfo", foreign_key: "keylocker_info_id"
  belongs_to :giver, class_name: "Employee", foreign_key: "giver_employee_id"
  belongs_to :receiver, class_name: "Employee", foreign_key: "receiver_employee_id"
  belongs_to :keylocker, optional: true

  validates :keylocker_info_id, :giver_employee_id, :receiver_employee_id, presence: true
end
