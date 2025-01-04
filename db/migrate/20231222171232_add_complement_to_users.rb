class AddComplementToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :complement, :string
  end
end
