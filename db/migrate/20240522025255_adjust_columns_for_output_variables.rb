class AdjustColumnsForOutputVariables < ActiveRecord::Migration[7.1]
  def change
    remove_column :outputs, :clip_length
    add_column :outputs, :script, :text
  end
end
