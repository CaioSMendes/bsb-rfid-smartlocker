class CreateKeyUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :key_usages do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :keylocker, null: false, foreign_key: true
      t.string :keys
      t.string :status
      t.datetime :action_time

      t.timestamps
    end
  end
end
