class CreateDeliverers < ActiveRecord::Migration[7.0]
  def change
    create_table :deliverers do |t|
      t.string :name
      t.string :lastname
      t.string :phone
      t.string :email
      t.string :cpf
      t.string :password
      t.bigint :keylocker_id
      t.boolean :enabled

      t.timestamps
    end
  end
end
