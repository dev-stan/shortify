class AddFontSizeToOutputs < ActiveRecord::Migration[7.1]
  def change
    add_column :outputs, :font_size, :integer
    add_column :outputs, :font_style, :string
    add_column :outputs, :font_family, :string
  end
end
