class AddReferenceToOutputs < ActiveRecord::Migration[7.1]
  def change
    add_reference :outputs, :batch, null: false, foreign_key: true
  end
end
