class CreateEmployeesKeylockers < ActiveRecord::Migration[7.0]
  def change
    create_table :employees_keylockers do |t|
      t.belongs_to :employee, foreign_key: true
      t.belongs_to :keylocker, foreign_key: true

      t.timestamps
    end
  end
end
