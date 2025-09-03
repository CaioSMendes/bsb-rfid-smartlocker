class AddEmptyAtMomentToKeylockerTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :keylocker_transactions, :empty_at_moment, :integer
  end
end
