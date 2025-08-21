class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :lastname
      t.string :companyID
      t.string :phone
      t.string :email
      t.string :function
      t.string :PIN
      t.string :cpf
      t.string :pswdSmartlocker
      t.string :cardRFID
      t.string :status
      t.string :matricula
      t.boolean :operator, default: true, null: false 
      t.boolean :delivery, default: true, null: false 
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end
  end
end