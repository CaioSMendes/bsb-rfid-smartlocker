class CreateKeylockers < ActiveRecord::Migration[7.0]
  def change
    create_table :keylockers do |t|
      t.string :owner
      t.string :nameDevice
      t.string :cnpjCpf
      t.integer :qtd
      t.string :serial
      t.string :status
      t.string :lockertype
      t.timestamps
    end
  end
end