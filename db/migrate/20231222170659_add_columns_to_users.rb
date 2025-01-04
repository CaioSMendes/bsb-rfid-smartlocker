class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :neighborhood, :string
    add_column :users, :finance, :string
  end
end
