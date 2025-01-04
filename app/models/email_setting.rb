class EmailSetting < ApplicationRecord
    validates :address, :port, :user_name, :password, :authentication, presence: true
    validates :enable_starttls_auto, inclusion: { in: [true, false] }
end
