class CreateGyms < ActiveRecord::Migration[7.2]
  def change
    create_table :gyms do |t|
      t.string :name, null: false
      t.string :address
      t.string :ward
      t.string :nearest_station
      t.string :phone
      t.string :website
      t.string :reservation_url
      t.text :notes

      t.timestamps
    end
  end
end
