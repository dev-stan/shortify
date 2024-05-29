class AddReferenceToBatches < ActiveRecord::Migration[7.1]
  def change
    add_reference :batches, :source, null: false, foreign_key: true
  end
end
