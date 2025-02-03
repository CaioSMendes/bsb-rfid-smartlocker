class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :package_description
      t.string :locker_code
      t.string :pin
      t.string :full_address
      t.string :imageEntregador
      t.string :imageInvoice
      t.string :imageProduct

      t.timestamps
    end
  end
end
