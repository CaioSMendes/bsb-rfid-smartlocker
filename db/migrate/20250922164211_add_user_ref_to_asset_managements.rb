class AddUserRefToAssetManagements < ActiveRecord::Migration[7.0]
  def change
    add_reference :asset_managements, :user, foreign_key: true
  end
end