class CreateKeylockerinfos < ActiveRecord::Migration[7.0]
  def change
    create_table :keylockerinfos do |t|
      t.string :object
      t.integer :posicion
      t.integer :empty, default: 1, null: false  # Coluna 'empty' adicionada com valor padrão 1
      t.references :keylocker, null: false, foreign_key: true

      t.timestamps
    end
  end
end
