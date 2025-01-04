class CreateKeylogs < ActiveRecord::Migration[7.0]
  def change
    create_table :keylogs do |t|
      t.integer :position
      t.string :status

      t.timestamps
    end
  end
end
