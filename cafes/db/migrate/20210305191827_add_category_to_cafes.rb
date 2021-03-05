class AddCategoryToCafes < ActiveRecord::Migration[6.0]
  def change
    add_column :cafes, :category, :string
  end
end
