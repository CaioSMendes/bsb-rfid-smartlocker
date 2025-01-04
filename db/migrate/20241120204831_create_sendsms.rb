class CreateSendsms < ActiveRecord::Migration[7.0]
  def change
    create_table :sendsms do |t|
      t.string :user
      t.string :password
      t.text :msg
      t.string :url
      t.string :hashSeguranca

      t.timestamps
    end
  end
end
