class CreateBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :batches do |t|
      t.integer "voice"
      t.string "font_family"
      t.integer "font_size"
      t.string "font_style"

      t.timestamps
    end
  end
end
