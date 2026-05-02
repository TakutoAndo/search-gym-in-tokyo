class CreateGymSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :gym_schedules do |t|
      t.references :gym, null: false, foreign_key: true
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time
      t.integer :price
      t.text :notes

      t.timestamps
    end
  end
end
