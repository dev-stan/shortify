class RemoveForeignKey < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :sources, column: :user_id
  end
end
