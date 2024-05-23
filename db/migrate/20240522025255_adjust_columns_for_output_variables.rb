class AdjustColumnsForOutputVariables < ActiveRecord::Migration[7.1]
  def change
    add_column :outputs, :script, :text
  end
end
