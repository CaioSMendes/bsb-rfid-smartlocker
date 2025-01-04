class AddDoorToKeylockers < ActiveRecord::Migration[7.0]
  def change
    add_column :keylockers, :door, :string, default: "fechado"
  end
end
