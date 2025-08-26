class AddKeylockerToLogsmovimetations < ActiveRecord::Migration[7.0]
  def change
    add_reference :logsmovimetations, :keylocker, null: false, foreign_key: true
  end
end
