class NewColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :outputs, :voice, :integer
  end
end
