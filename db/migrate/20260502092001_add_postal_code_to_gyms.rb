class AddPostalCodeToGyms < ActiveRecord::Migration[7.2]
  def change
    add_column :gyms, :postal_code, :string
  end
end
