class RemoveColumns < ActiveRecord::Migration[7.1]
  def change
    remove_column :sources, :url, :string
    remove_column :sources, :youtube_id, :string
  end
end
