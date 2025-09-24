class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.references :asset_management, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.string :name
      t.string :tagRFID
      t.string :idInterno
      t.integer :qtdDigito
      t.string :description
      t.string :image
      t.string :status
      t.integer :empty, default: 1, null: false  # Coluna 'empty' adicionada com valor padrão 1

      t.timestamps
    end
  end
end
