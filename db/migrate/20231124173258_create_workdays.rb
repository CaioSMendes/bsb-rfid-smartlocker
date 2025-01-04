class CreateWorkdays < ActiveRecord::Migration[7.0]
  def change
    create_table :workdays do |t|
      t.time :start, null: false
      t.time :end, null: false
      t.boolean :monday, default: false
      t.boolean :tuesday, default: false
      t.boolean :wednesday, default: false
      t.boolean :thursday, default: false
      t.boolean :friday, default: false
      t.boolean :saturday, default: false
      t.boolean :sunday, default: false
      t.boolean :enabled, default: true, null: false # Campo para habilitar/gerenciar horário de trabalho


      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
