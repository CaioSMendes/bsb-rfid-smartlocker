class CreateHistoryEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :history_entries do |t|
      t.string :owner
      t.string :name_device
      t.json :employee_info
      t.json :keys_taken, default: []
      t.json :keys_returned, default: []
      t.json :sequence_order, default: []
      t.string :datahistory

      t.timestamps
    end
  end
end