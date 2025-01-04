class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :name, :string
    add_column :users, :lastname, :string
    add_column :users, :cnpj, :string
    add_column :users, :nameCompany, :string
  end
end
