class RemoveFkeyColumn < ActiveRecord::Migration[7.1]
  def change
    remove_column :sources, :user_id, :integer
  end
end
