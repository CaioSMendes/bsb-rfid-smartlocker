class AddKeylockerIdToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :logs, :keylocker_id, :integer
  end
end
