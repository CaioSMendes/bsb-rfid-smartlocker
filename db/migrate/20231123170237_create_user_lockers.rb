class CreateUserLockers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_lockers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :keylocker, null: false, foreign_key: true

      t.timestamps
    end
  end
end
