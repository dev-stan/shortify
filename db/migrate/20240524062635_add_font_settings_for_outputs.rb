class AddFontSettingsForOutputs < ActiveRecord::Migration[7.1]
  def change
    add_column :sources, :font_size, :integer
    add_column :sources, :font_style, :string
    add_column :sources, :font_family, :string
  end
end
