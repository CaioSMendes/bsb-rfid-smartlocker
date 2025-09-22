class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :name, :string
    add_column :users, :lastname, :string
    add_column :users, :cnpj, :string
    add_column :users, :nameCompany, :string
    add_column :users, :assetManagement, :boolean, default: false
    add_column :users, :lockerControl, :boolean, default: false
  end
end
