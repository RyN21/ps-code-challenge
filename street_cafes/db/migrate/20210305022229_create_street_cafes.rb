class CreateStreetCafes < ActiveRecord::Migration[6.0]
  def change
    create_table :street_cafes do |t|
      t.string :name
      t.string :street_address
      t.string :post_code
      t.string :num_of_chairs

      t.timestamps
    end
  end
end
