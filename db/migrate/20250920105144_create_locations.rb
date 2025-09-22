class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :code
      t.string :address
      t.text :description
      t.references :asset_management, null: false, foreign_key: true

      t.timestamps
    end
  end
end
