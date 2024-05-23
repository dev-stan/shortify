class AddUrlToSources < ActiveRecord::Migration[7.1]
  def change
    add_column :sources, :url, :string
    add_column :sources, :location, :string
  end
end
