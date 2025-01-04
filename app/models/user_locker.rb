class UserLocker < ApplicationRecord
  belongs_to :user
  belongs_to :keylocker
end
