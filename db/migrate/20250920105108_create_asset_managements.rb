class CreateAssetManagements < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_managements do |t|
      t.string :name
      t.text :description
      t.string :serial

      t.timestamps
    end
  end
end
