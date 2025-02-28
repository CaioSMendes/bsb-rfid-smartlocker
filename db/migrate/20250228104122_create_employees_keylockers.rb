class CreateEmployeesKeylockers < ActiveRecord::Migration[7.0]
  def change
    create_table :employees_keylockers do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :keylocker, null: false, foreign_key: true

      t.timestamps
    end
  end
end
