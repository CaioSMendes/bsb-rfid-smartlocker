class AddMovementDescriptionToKeylockerTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :keylocker_transactions, :movement_description, :string
  end
end
