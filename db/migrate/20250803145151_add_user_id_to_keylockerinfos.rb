class AddUserIdToKeylockerinfos < ActiveRecord::Migration[7.0]
  def change
    add_column :keylockerinfos, :user_id, :bigint
  end
end
