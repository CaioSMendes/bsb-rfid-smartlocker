class CreateKeylockerTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :keylocker_transactions do |t|
      t.bigint :keylocker_info_id, null: false        # objeto
      t.bigint :giver_employee_id, null: false        # quem entrega
      t.bigint :receiver_employee_id, null: false     # quem recebe
      t.bigint :keylocker_id                           # locker usado
      t.string :status, null: false, default: "disponível"  # status do objeto: 'em_uso' ou 'disponível'
      t.datetime :delivered_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :keylocker_transactions, :keylocker_info_id
    add_index :keylocker_transactions, :giver_employee_id
    add_index :keylocker_transactions, :receiver_employee_id
    add_index :keylocker_transactions, :keylocker_id
  end
end
