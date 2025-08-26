class CreateLogsmovimetations < ActiveRecord::Migration[7.0]
  def change
    create_table :logsmovimetations do |t|
      t.references :employee, null: false, foreign_key: true
      t.string "action"  # Pode ser 'entrada' ou 'saída'
      t.string "tagrfid"  # Pode ser 'entrada' ou 'saída'
      t.string "key_id"  # Exemplo: 'LS 10000001'
      t.string "locker_name"  # Nome do locker ou dispositivo
      t.string "locker_serial"
      t.string "locker_object"
      t.datetime "timestamp"  # Hora e data da ação
      t.string "status"  # Status do locker (aberto, fechado)
      t.text "comments"  # Comentários adicionais

      t.timestamps
    end
  end
end
