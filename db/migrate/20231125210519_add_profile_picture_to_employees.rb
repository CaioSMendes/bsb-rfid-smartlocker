class AddProfilePictureToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :profile_picture, :string
  end
end
