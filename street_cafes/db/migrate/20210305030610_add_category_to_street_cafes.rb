class AddCategoryToStreetCafes < ActiveRecord::Migration[6.0]
  def change
    add_column :street_cafes, :category, :string
  end
end
