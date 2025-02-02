class CreateDeliveries < ActiveRecord::Migration[7.0]
  def change
    create_table :deliveries do |t|
      t.string :package_description
      t.bigint :deliverer_id
      t.bigint :employee_id
      t.datetime :delivery_date
      t.string :locker_code
      t.string :full_address
      t.string :imageEntregador
      t.string :imageInvoice
      t.string :imageProduct
      #t.string :serial

      t.timestamps
    end
  end
end
