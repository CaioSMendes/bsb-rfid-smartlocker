class CreateEmailSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :email_settings do |t|
      t.string :address
      t.integer :port
      t.string :user_name
      t.string :password
      t.string :authentication
      t.boolean :enable_starttls_auto
      t.boolean :tls


      t.timestamps
    end
  end
end



