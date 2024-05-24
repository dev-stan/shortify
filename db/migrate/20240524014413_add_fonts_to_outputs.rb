class AddFontsToOutputs < ActiveRecord::Migration[7.1]
  def change
    add_column :outputs, :font_family, :string
    add_column :outputs, :font_style, :string
  end
end
