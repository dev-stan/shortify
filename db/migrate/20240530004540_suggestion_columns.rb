class SuggestionColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :outputs, :suggested_title, :string
    add_column :outputs, :suggested_description, :string
    add_column :outputs, :suggested_hashtags, :string
  end
end
