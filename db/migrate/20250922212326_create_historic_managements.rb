class CreateHistoricManagements < ActiveRecord::Migration[7.0]
  def change
    create_table :historic_managements do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.text :description
      t.datetime :action_time

      t.timestamps
    end
  end
end
