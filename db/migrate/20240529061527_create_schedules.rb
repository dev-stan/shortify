class CreateSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :schedules do |t|
      t.datetime :publish_time
      t.references :output, null: false, foreign_key: true
      t.string :platform

      t.timestamps
    end
  end
end
