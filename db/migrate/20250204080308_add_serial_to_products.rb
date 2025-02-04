class AddSerialToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :serial, :string
  end
end
